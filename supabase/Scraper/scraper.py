"""
scraper.py — سكرابر نتائج المباريات المباشرة من Yallakora
يشتغل في حلقة مستمرة لمدة 5 دقائق (280 ثانية)
كل 30 ثانية يجلب البيانات ويحدّث قاعدة البيانات

الاستخدام:
  python scraper.py              # تشغيل الحلقة الكاملة
  python scraper.py --once       # تشغيل مرة واحدة فقط (للاختبار)
  python scraper.py --dry-run    # جلب البيانات بدون تحديث الـ DB
"""

import sys
import time
import logging
import argparse
import re
from datetime import datetime, timezone, timedelta

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # في بيئة CI/CD الـ env vars تكون جاهزة

from playwright.sync_api import sync_playwright

from database import get_session, upsert_matches

# ──────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────

YALLAKORA_URL = "https://www.yallakora.com/match-center/"
LOOP_DURATION_SECONDS = 280   # 4 دقائق و 40 ثانية (أقل من GitHub Actions timeout)
SLEEP_INTERVAL_SECONDS = 30   # كل 30 ثانية
USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/131.0.0.0 Safari/537.36"
)

# ──────────────────────────────────────────────
# Logging
# ──────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-7s | %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)


# ──────────────────────────────────────────────
# Scraping Logic
# ──────────────────────────────────────────────


def parse_score(score_text: str) -> tuple[int, int]:
    """تحويل نص النتيجة إلى أرقام. مثال: '2 - 1' → (2, 1)"""
    score_text = score_text.strip()
    # Try common separators
    for sep in ["-", "–", ":"]:
        if sep in score_text:
            parts = score_text.split(sep)
            try:
                return int(parts[0].strip()), int(parts[1].strip())
            except (ValueError, IndexError):
                continue
    return 0, 0


def parse_minute(minute_text: str) -> int:
    """
    تحويل نص الدقيقة إلى رقم.
    أمثلة: "45'" → 45, "45+2'" → 47, "HT" → 45, "FT" → 90
    """
    minute_text = minute_text.strip().replace("'", "").replace("′", "")

    if minute_text in ("HT", "ش.أ", "نهاية الشوط"):
        return 45
    if minute_text in ("FT", "ن.م", "نهاية المباراة"):
        return 90

    # Handle "45+2" format
    match = re.match(r"(\d+)\+(\d+)", minute_text)
    if match:
        return int(match.group(1)) + int(match.group(2))

    try:
        return int(minute_text)
    except ValueError:
        return 0


def map_status(status_text: str) -> str:
    """تحويل حالة المباراة من النص العربي/الإنجليزي إلى enum الـ DB."""
    status_lower = status_text.strip().lower()

    live_keywords = [
        "live", "مباشر", "جارية", "الشوط", "شوط", "ش.أ", "ش.ث",
        "بدأت", "استراحة", "ht", "extra", "إضافي",
    ]
    finished_keywords = [
        "finished", "ft", "انتهت", "ن.م", "نهاية", "ended",
    ]

    for kw in live_keywords:
        if kw in status_lower:
            return "live"
    for kw in finished_keywords:
        if kw in status_lower:
            return "finished"

    return "upcoming"


def scrape_matches(page) -> list[dict]:
    """
    جلب بيانات المباريات من صفحة Yallakora.
    يرجع قائمة dictionaries جاهزة للـ upsert.
    """
    matches = []
    today = datetime.now(timezone.utc).date()

    try:
        # Navigate
        page.goto(YALLAKORA_URL, wait_until="domcontentloaded", timeout=30000)
        page.wait_for_timeout(3000)  # Wait for JS to render

        # Try multiple selectors (Yallakora changes layout occasionally)
        match_containers = page.query_selector_all(
            ".matchCard, .match-card, .liItem, .item, [class*='match']"
        )

        if not match_containers:
            # Fallback: try the main content area
            match_containers = page.query_selector_all(
                "#matchesContainer .item, .allData .item, .matchesList .item"
            )

        logger.info(f"📦 وُجد {len(match_containers)} عنصر مباراة في الصفحة")

        for container in match_containers:
            try:
                match_data = extract_match_from_element(container, today)
                if match_data:
                    matches.append(match_data)
            except Exception as e:
                logger.debug(f"⏭️ تخطي عنصر: {e}")
                continue

    except Exception as e:
        logger.error(f"❌ خطأ في جلب الصفحة: {e}")

    return matches


def extract_match_from_element(element, today) -> dict | None:
    """
    استخراج بيانات مباراة واحدة من عنصر HTML.
    يحاول عدة selectors مختلفة.
    """
    # ── Team Names & Logos ──
    team_elements = element.query_selector_all(
        ".teamName, .team-name, .teamA, .teamB, .team, [class*='team']"
    )
    
    home_team = ""
    away_team = ""
    home_logo = ""
    away_logo = ""

    if len(team_elements) >= 2:
        # Extract name
        home_team = team_elements[0].query_selector(".name, span, strong") or team_elements[0]
        home_team = home_team.inner_text().strip()
        
        away_team = team_elements[1].query_selector(".name, span, strong") or team_elements[1]
        away_team = away_team.inner_text().strip()

        # Extract logo
        home_img = team_elements[0].query_selector("img")
        if home_img:
            home_logo = home_img.get_attribute("src") or home_img.get_attribute("data-src") or ""
            
        away_img = team_elements[1].query_selector("img")
        if away_img:
            away_logo = away_img.get_attribute("src") or away_img.get_attribute("data-src") or ""

    if not home_team or not away_team:
        # Fallback to text splitting if selectors fail
        all_text = element.inner_text().strip().split("\n")
        all_text = [t.strip() for t in all_text if t.strip()]
        # Heuristic: Find localized text
        if len(all_text) >= 2:
             # Basic fallback, no logos here
             home_team = all_text[0] 
             away_team = all_text[-1]

    if not home_team or not away_team:
        return None

    # ── Score ──
    score_el = element.query_selector(
        ".score, .result, .matchResult, [class*='score'], [class*='result']"
    )
    home_score, away_score = 0, 0
    if score_el:
        score_text = score_el.inner_text().strip()
        home_score, away_score = parse_score(score_text)

    # ── Status / Minute ──
    status_el = element.query_selector(
        ".matchStatus, .status, .time, .matchTime, [class*='status'], [class*='live']"
    )
    status_text = ""
    minute = 0
    if status_el:
        status_text = status_el.inner_text().strip()
        status = map_status(status_text)
        if status == "live":
            minute = parse_minute(status_text)
    else:
        status = "upcoming"

    # ── League ──
    league_el = element.query_selector(
        ".championship, .league, .tournamentName, .tourName, [class*='champ'], [class*='league']"
    )
    league_name = league_el.inner_text().strip() if league_el else ""

    # ── Time ──
    time_el = element.query_selector(
        ".matchTime, .time, [class*='time']"
    )
    match_time = datetime.now(timezone.utc)
    if time_el and status == "upcoming":
        time_text = time_el.inner_text().strip()
        time_match = re.search(r"(\d{1,2}):(\d{2})", time_text)
        if time_match:
            hour, mins = int(time_match.group(1)), int(time_match.group(2))
            match_time = datetime.combine(
                today,
                datetime.min.time().replace(hour=hour, minute=mins),
                tzinfo=timezone.utc,
            )

    # ── Channel ──
    channel_el = element.query_selector(
        ".channel, [class*='channel'], [class*='broadcaster']"
    )
    channel = channel_el.inner_text().strip() if channel_el else ""

    # ── Round ──
    round_el = element.query_selector(
        ".round, .matchRound, [class*='round'], [class*='week']"
    )
    round_name = round_el.inner_text().strip() if round_el else ""

    return {
        "home_team_name": home_team,
        "away_team_name": away_team,
        "home_team_logo": home_logo,
        "away_team_logo": away_logo,
        "home_score": home_score,
        "away_score": away_score,
        "status": status,
        "minute": minute,
        "league_name": league_name,
        "start_time": match_time,
        "channel": channel,
        "round": round_name,
    }


# ──────────────────────────────────────────────
# Main Loop
# ──────────────────────────────────────────────


def run_scraper(once: bool = False, dry_run: bool = False):
    """
    حلقة السكرابر الرئيسية.
    
    Args:
        once: تشغيل مرة واحدة فقط (للاختبار)
        dry_run: جلب البيانات بدون تحديث الـ DB
    """
    logger.info("=" * 50)
    logger.info("⚽ سكرابر Kora — بداية التشغيل")
    logger.info(f"   الوضع: {'مرة واحدة' if once else f'حلقة {LOOP_DURATION_SECONDS}s'}")
    logger.info(f"   الـ DB: {'معطّل (dry-run)' if dry_run else 'مفعّل'}")
    logger.info("=" * 50)

    start_time = time.time()
    iteration = 0

    with sync_playwright() as p:
        logger.info("🌐 تشغيل المتصفح...")
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--disable-gpu",
            ],
        )
        context = browser.new_context(
            user_agent=USER_AGENT,
            viewport={"width": 1280, "height": 720},
            locale="ar-SA",
        )

        # Apply stealth
        try:
            from playwright_stealth import stealth_sync
            page = context.new_page()
            stealth_sync(page)
        except ImportError:
            logger.warning("⚠️ playwright-stealth غير مثبّت — متابعة بدون stealth")
            page = context.new_page()

        while True:
            elapsed = time.time() - start_time
            if not once and elapsed >= LOOP_DURATION_SECONDS:
                logger.info(f"⏰ انتهى الوقت ({int(elapsed)}s) — إيقاف")
                break

            iteration += 1
            logger.info(f"\n{'─' * 40}")
            logger.info(f"🔄 الدورة #{iteration} | {int(elapsed)}s من {LOOP_DURATION_SECONDS}s")
            logger.info(f"{'─' * 40}")

            try:
                # 1. Scrape
                matches = scrape_matches(page)
                logger.info(f"📊 تم جلب {len(matches)} مباراة")

                # 2. Prioritize live matches
                live = [m for m in matches if m["status"] == "live"]
                other = [m for m in matches if m["status"] != "live"]
                sorted_matches = live + other

                if live:
                    logger.info(f"🔴 {len(live)} مباراة مباشرة!")

                # 3. Log matches
                for m in sorted_matches:
                    status_emoji = {"live": "🔴", "finished": "🏁", "upcoming": "⏳"}.get(
                        m["status"], "❓"
                    )
                    logger.info(
                        f"  {status_emoji} {m['home_team_name']} "
                        f"{m['home_score']}-{m['away_score']} "
                        f"{m['away_team_name']} "
                        f"({m.get('league_name', '?')})"
                    )

                # 4. Upsert to DB
                if not dry_run and sorted_matches:
                    try:
                        session = get_session()
                        stats = upsert_matches(session, sorted_matches)
                        session.close()
                        logger.info(
                            f"💾 DB: {stats['updated']} تحديث | "
                            f"{stats['skipped']} تخطي"
                        )
                    except Exception as e:
                        logger.error(f"❌ خطأ في الـ DB: {e}")

            except Exception as e:
                logger.error(f"❌ خطأ في الدورة #{iteration}: {e}")

            if once:
                logger.info("✅ انتهى (وضع المرة الواحدة)")
                break

            # Sleep
            remaining = LOOP_DURATION_SECONDS - (time.time() - start_time)
            sleep_time = min(SLEEP_INTERVAL_SECONDS, remaining)
            if sleep_time > 0:
                logger.info(f"💤 انتظار {int(sleep_time)}s...")
                time.sleep(sleep_time)

        browser.close()

    logger.info("=" * 50)
    logger.info(f"🏁 انتهى السكرابر — {iteration} دورة في {int(time.time() - start_time)}s")
    logger.info("=" * 50)


# ──────────────────────────────────────────────
# Entry Point
# ──────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="⚽ Kora Live Scores Scraper")
    parser.add_argument(
        "--once",
        action="store_true",
        help="تشغيل مرة واحدة فقط (للاختبار)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="جلب البيانات بدون تحديث قاعدة البيانات",
    )
    args = parser.parse_args()

    run_scraper(once=args.once, dry_run=args.dry_run)
