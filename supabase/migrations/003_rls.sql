-- ============================================================
-- شوف TV — Row Level Security Policies
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leagues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_lineups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.standings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.streaming_servers ENABLE ROW LEVEL SECURITY;

-- ──────────────────────────────────────────────────────────────
-- profiles: user can read/update only their own
-- ──────────────────────────────────────────────────────────────
CREATE POLICY "Users can read own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- ──────────────────────────────────────────────────────────────
-- user_preferences: user can CRUD only their own
-- ──────────────────────────────────────────────────────────────
CREATE POLICY "Users can read own preferences"
  ON public.user_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
  ON public.user_preferences FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
  ON public.user_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ──────────────────────────────────────────────────────────────
-- Public read for content tables
-- ──────────────────────────────────────────────────────────────
CREATE POLICY "Public read leagues"
  ON public.leagues FOR SELECT
  USING (true);

CREATE POLICY "Public read teams"
  ON public.teams FOR SELECT
  USING (true);

CREATE POLICY "Public read matches"
  ON public.matches FOR SELECT
  USING (true);

CREATE POLICY "Public read match_events"
  ON public.match_events FOR SELECT
  USING (true);

CREATE POLICY "Public read match_lineups"
  ON public.match_lineups FOR SELECT
  USING (true);

CREATE POLICY "Public read standings"
  ON public.standings FOR SELECT
  USING (true);

CREATE POLICY "Public read player_stats"
  ON public.player_stats FOR SELECT
  USING (true);

CREATE POLICY "Public read news"
  ON public.news FOR SELECT
  USING (true);

-- ──────────────────────────────────────────────────────────────
-- streaming_servers: authenticated users only
-- ──────────────────────────────────────────────────────────────
CREATE POLICY "Authenticated users can read streams"
  ON public.streaming_servers FOR SELECT
  USING (auth.role() = 'authenticated');
