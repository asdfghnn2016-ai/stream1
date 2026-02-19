-- ============================================================
-- شوف TV — Realtime Subscriptions
-- ============================================================

-- Enable realtime for live data tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.matches;
ALTER PUBLICATION supabase_realtime ADD TABLE public.standings;
ALTER PUBLICATION supabase_realtime ADD TABLE public.match_events;
