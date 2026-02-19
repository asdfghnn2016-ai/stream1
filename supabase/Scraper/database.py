"""
database.py — طبقة قاعدة البيانات لسكرابر Kora
يستخدم SQLAlchemy مع Upsert (INSERT ON CONFLICT UPDATE)
"""

import os
import logging
from datetime import datetime, timezone

from sqlalchemy import (
    create_engine,
    Column,
    String,
    Integer,
    Boolean,
    DateTime,
    Numeric,
    Text,
    ARRAY,
    text,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB, insert
from sqlalchemy.orm import declarative_base, sessionmaker, Session

logger = logging.getLogger(__name__)

Base = declarative_base()


# ──────────────────────────────────────────────
# Models (mirrors Supabase schema)
# ──────────────────────────────────────────────


class League(Base):
    __tablename__ = "leagues"
    __table_args__ = {"schema": "public"}

    id = Column(UUID(as_uuid=True), primary_key=True)
    name = Column(Text, nullable=False)
    logo_url = Column(Text, default="")
    country = Column(Text, nullable=False)
    season = Column(Text, default="2025-2026")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.now(timezone.utc))


class Team(Base):
    __tablename__ = "teams"
    __table_args__ = {"schema": "public"}

    id = Column(UUID(as_uuid=True), primary_key=True)
    league_id = Column(UUID(as_uuid=True))
    name = Column(Text, nullable=False)
    short_name = Column(Text)
    logo_url = Column(Text, default="")
    created_at = Column(DateTime(timezone=True), default=datetime.now(timezone.utc))


class Match(Base):
    __tablename__ = "matches"
    __table_args__ = {"schema": "public"}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("uuid_generate_v4()"))
    league_id = Column(UUID(as_uuid=True))
    home_team_id = Column(UUID(as_uuid=True))
    away_team_id = Column(UUID(as_uuid=True))
    start_time = Column(DateTime(timezone=True), nullable=False)
    status = Column(Text, default="upcoming")
    home_score = Column(Integer, default=0)
    away_score = Column(Integer, default=0)
    minute = Column(Integer, default=0)
    venue = Column(Text, default="")
    referee = Column(Text, default="")
    channel = Column(Text, default="")
    commentator = Column(Text, default="")
    round = Column(Text, default="")
    home_formation = Column(Text, default="4-3-3")
    away_formation = Column(Text, default="4-3-3")
    created_at = Column(DateTime(timezone=True), default=datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=datetime.now(timezone.utc))


class MatchEvent(Base):
    __tablename__ = "match_events"
    __table_args__ = {"schema": "public"}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("uuid_generate_v4()"))
    match_id = Column(UUID(as_uuid=True))
    minute = Column(Integer, nullable=False)
    event_type = Column(Text, nullable=False)
    player_name = Column(Text, nullable=False)
    team_id = Column(UUID(as_uuid=True))
    description = Column(Text, default="")
    created_at = Column(DateTime(timezone=True), default=datetime.now(timezone.utc))


# ──────────────────────────────────────────────
# Database Connection
# ──────────────────────────────────────────────


def get_engine():
    """Create SQLAlchemy engine from DATABASE_URL env var."""
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        raise ValueError(
            "❌ DATABASE_URL غير موجود! "
            "ضيفه في .env أو GitHub Secrets."
        )
    return create_engine(database_url, pool_pre_ping=True, echo=False)


def get_session() -> Session:
    """Create a new database session."""
    engine = get_engine()
    SessionLocal = sessionmaker(bind=engine)
    return SessionLocal()


# ──────────────────────────────────────────────
# Team & League Lookup (Get or Create)
# ──────────────────────────────────────────────

_team_cache: dict[str, str] = {}    # name -> uuid
_league_cache: dict[str, str] = {}  # name -> uuid


def get_or_create_league(session: Session, league_name: str) -> str | None:
    """البحث عن الدوري أو إنشاؤه إذا لم يكن موجوداً."""
    if not league_name:
        return None

    if league_name in _league_cache:
        return _league_cache[league_name]

    # بحث مطابق تمامًا
    league = session.query(League).filter(League.name == league_name).first()

    # بحث جزئي (ILIKE)
    if not league:
        league = session.query(League).filter(League.name.ilike(f"%{league_name}%")).first()

    # Create if not found
    if not league:
        logger.info(f"🆕 إنشاء دوري جديد: {league_name}")
        league = League(name=league_name, country="Unknown")
        session.add(league)
        session.flush()  # To get ID

    _league_cache[league_name] = str(league.id)
    return str(league.id)


def get_or_create_team(session: Session, team_name: str, logo_url: str = "", league_id: str = None) -> str:
    """
    البحث عن الفريق بالاسم العربي أو إنشاؤه.
    """
    if team_name in _team_cache:
        # Update logo if needed (optional optimization)
        return _team_cache[team_name]

    # بحث مطابق تمامًا
    team = session.query(Team).filter(Team.name == team_name).first()

    # بحث جزئي
    if not team:
        team = session.query(Team).filter(Team.name.ilike(f"%{team_name}%")).first()
    
    # Create if not found
    if not team:
        logger.info(f"🆕 إنشاء فريق جديد: {team_name}")
        team = Team(
            name=team_name,
            logo_url=logo_url,
            league_id=league_id
        )
        session.add(team)
        session.flush()

    _team_cache[team_name] = str(team.id)
    return str(team.id)


# ──────────────────────────────────────────────
# Upsert Logic
# ──────────────────────────────────────────────


def upsert_match(session: Session, match_data: dict) -> bool:
    """
    إدراج أو تحديث مباراة باستخدام Upsert.
    
    match_data يجب أن يحتوي على:
      - home_team_name: اسم الفريق المضيف
      - away_team_name: اسم الفريق الضيف
      - league_name: اسم الدوري
      - home_score: أهداف المضيف
      - away_score: أهداف الضيف
      - status: live / upcoming / finished
      - minute: الدقيقة الحالية
      - start_time: وقت البداية (datetime)
      - round: الجولة (اختياري)
      - channel: القناة (اختياري)
    
    Returns: True if upserted, False if skipped (team not found)
    """
    league_id = get_or_create_league(session, match_data.get("league_name", ""))

    home_id = get_or_create_team(
        session, 
        match_data["home_team_name"], 
        match_data.get("home_team_logo", ""),
        league_id
    )
    away_id = get_or_create_team(
        session, 
        match_data["away_team_name"], 
        match_data.get("away_team_logo", ""),
        league_id
    )

    if not home_id or not away_id:
        # Should not happen with create logic, but safety check
        return False

    # Check if match already exists (same teams, same date)
    start_date = match_data["start_time"].date() if isinstance(match_data["start_time"], datetime) else match_data["start_time"]
    
    existing = session.execute(
        text("""
            SELECT id FROM public.matches
            WHERE home_team_id = :home_id
              AND away_team_id = :away_id
              AND start_time::date = :match_date
            LIMIT 1
        """),
        {
            "home_id": home_id,
            "away_id": away_id,
            "match_date": str(start_date),
        },
    ).fetchone()

    now = datetime.now(timezone.utc)

    if existing:
        # UPDATE existing match
        session.execute(
            text("""
                UPDATE public.matches
                SET status = :status,
                    home_score = :home_score,
                    away_score = :away_score,
                    minute = :minute,
                    updated_at = :updated_at
                WHERE id = :match_id
            """),
            {
                "match_id": str(existing[0]),
                "status": match_data.get("status", "upcoming"),
                "home_score": match_data.get("home_score", 0),
                "away_score": match_data.get("away_score", 0),
                "minute": match_data.get("minute", 0),
                "updated_at": now,
            },
        )
        logger.info(
            f"🔄 تحديث: {match_data['home_team_name']} {match_data.get('home_score', 0)}"
            f"-{match_data.get('away_score', 0)} {match_data['away_team_name']} "
            f"(د{match_data.get('minute', 0)})"
        )
    else:
        # INSERT new match
        session.execute(
            text("""
                INSERT INTO public.matches
                    (league_id, home_team_id, away_team_id, start_time,
                     status, home_score, away_score, minute,
                     channel, round, updated_at)
                VALUES
                    (:league_id, :home_id, :away_id, :start_time,
                     :status, :home_score, :away_score, :minute,
                     :channel, :round, :updated_at)
            """),
            {
                "league_id": league_id,
                "home_id": home_id,
                "away_id": away_id,
                "start_time": match_data.get("start_time", now),
                "status": match_data.get("status", "upcoming"),
                "home_score": match_data.get("home_score", 0),
                "away_score": match_data.get("away_score", 0),
                "minute": match_data.get("minute", 0),
                "channel": match_data.get("channel", ""),
                "round": match_data.get("round", ""),
                "updated_at": now,
            },
        )
        logger.info(
            f"✅ إضافة: {match_data['home_team_name']} vs {match_data['away_team_name']}"
        )

    session.commit()
    return True


def upsert_matches(session: Session, matches: list[dict]) -> dict:
    """
    Upsert قائمة مباريات.
    Returns: {"updated": N, "inserted": N, "skipped": N}
    """
    stats = {"updated": 0, "inserted": 0, "skipped": 0}

    for match_data in matches:
        try:
            if upsert_match(session, match_data):
                stats["updated"] += 1
            else:
                stats["skipped"] += 1
        except Exception as e:
            logger.error(f"❌ خطأ في upsert: {e}")
            session.rollback()
            stats["skipped"] += 1

    return stats
