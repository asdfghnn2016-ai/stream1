-- ============================================================
-- شوف TV — Full Database Schema
-- Supabase PostgreSQL (Production-Ready)
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ──────────────────────────────────────────────────────────────
-- 1. profiles (linked to auth.users)
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT,
  display_name TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ──────────────────────────────────────────────────────────────
-- 2. user_preferences
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.user_preferences (
  user_id               UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  favorite_team_ids     UUID[] DEFAULT '{}',
  favorite_league_ids   UUID[] DEFAULT '{}',
  theme_mode            TEXT DEFAULT 'dark' CHECK (theme_mode IN ('dark', 'light', 'system')),
  font_scale_details    NUMERIC(3,2) DEFAULT 1.00,
  font_scale_news       NUMERIC(3,2) DEFAULT 1.00,
  notifications_enabled BOOLEAN DEFAULT true,
  match_notifications   BOOLEAN DEFAULT true,
  news_notifications    BOOLEAN DEFAULT true,
  match_sorting         TEXT DEFAULT 'tournament' CHECK (match_sorting IN ('tournament', 'time', 'important', 'favorite')),
  language_code         TEXT DEFAULT 'ar',
  created_at            TIMESTAMPTZ DEFAULT now(),
  updated_at            TIMESTAMPTZ DEFAULT now()
);

-- Auto-create preferences on profile creation
CREATE OR REPLACE FUNCTION public.handle_new_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_profile();

-- ──────────────────────────────────────────────────────────────
-- 3. leagues
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.leagues (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL,
  logo_url   TEXT DEFAULT '',
  country    TEXT NOT NULL,
  season     TEXT DEFAULT '2025-2026',
  is_active  BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────
-- 4. teams
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.teams (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  league_id  UUID REFERENCES public.leagues(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  short_name TEXT,
  logo_url   TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────
-- 5. matches
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.matches (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  league_id     UUID REFERENCES public.leagues(id) ON DELETE CASCADE,
  home_team_id  UUID REFERENCES public.teams(id),
  away_team_id  UUID REFERENCES public.teams(id),
  start_time    TIMESTAMPTZ NOT NULL,
  status        TEXT DEFAULT 'upcoming' CHECK (status IN ('live', 'upcoming', 'finished')),
  home_score    INT DEFAULT 0,
  away_score    INT DEFAULT 0,
  minute        INT DEFAULT 0,
  venue         TEXT DEFAULT '',
  referee       TEXT DEFAULT '',
  channel       TEXT DEFAULT '',
  commentator   TEXT DEFAULT '',
  round         TEXT DEFAULT '',
  home_formation TEXT DEFAULT '4-3-3',
  away_formation TEXT DEFAULT '4-3-3',
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────
-- 6. match_events
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.match_events (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  match_id    UUID REFERENCES public.matches(id) ON DELETE CASCADE,
  minute      INT NOT NULL,
  event_type  TEXT NOT NULL CHECK (event_type IN ('goal', 'yellow_card', 'red_card', 'substitution', 'penalty', 'own_goal', 'var')),
  player_name TEXT NOT NULL,
  team_id     UUID REFERENCES public.teams(id),
  description TEXT DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────
-- 7. match_lineups
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.match_lineups (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  match_id    UUID REFERENCES public.matches(id) ON DELETE CASCADE,
  team_id     UUID REFERENCES public.teams(id),
  player_name TEXT NOT NULL,
  player_number INT NOT NULL,
  position    TEXT NOT NULL CHECK (position IN ('GK', 'DF', 'MF', 'FW')),
  is_captain  BOOLEAN DEFAULT false,
  photo_url   TEXT DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────
-- 8. standings
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.standings (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  league_id     UUID REFERENCES public.leagues(id) ON DELETE CASCADE,
  team_id       UUID REFERENCES public.teams(id),
  position      INT NOT NULL,
  points        INT DEFAULT 0,
  played        INT DEFAULT 0,
  wins          INT DEFAULT 0,
  draws         INT DEFAULT 0,
  losses        INT DEFAULT 0,
  goals_for     INT DEFAULT 0,
  goals_against INT DEFAULT 0,
  form          TEXT[] DEFAULT '{}',
  xg            NUMERIC(5,2) DEFAULT 0.00,
  possession    NUMERIC(5,2) DEFAULT 0.00,
  pass_accuracy NUMERIC(5,2) DEFAULT 0.00,
  trend         TEXT DEFAULT 'same' CHECK (trend IN ('up', 'down', 'same')),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE (league_id, team_id)
);

-- ──────────────────────────────────────────────────────────────
-- 9. player_stats
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.player_stats (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  league_id       UUID REFERENCES public.leagues(id) ON DELETE CASCADE,
  team_id         UUID REFERENCES public.teams(id),
  player_name     TEXT NOT NULL,
  photo_url       TEXT DEFAULT '',
  goals           INT DEFAULT 0,
  assists         INT DEFAULT 0,
  matches_played  INT DEFAULT 0,
  xg              NUMERIC(5,2) DEFAULT 0.00,
  possession_avg  NUMERIC(5,2) DEFAULT 0.00,
  pass_accuracy   NUMERIC(5,2) DEFAULT 0.00,
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────
-- 10. news
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.news (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title       TEXT NOT NULL,
  subtitle    TEXT DEFAULT '',
  description TEXT DEFAULT '',
  image_url   TEXT DEFAULT '',
  category    TEXT DEFAULT 'عام' CHECK (category IN ('عاجل', 'انتقال', 'إصابة', 'ملخص', 'تحديثات', 'عام')),
  url         TEXT DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────
-- 11. streaming_servers
-- ──────────────────────────────────────────────────────────────
CREATE TABLE public.streaming_servers (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  match_id   UUID REFERENCES public.matches(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  url        TEXT NOT NULL,
  quality    TEXT DEFAULT '720p',
  priority   INT DEFAULT 1,
  is_backup  BOOLEAN DEFAULT false,
  headers    JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);
