-- ============================================================
-- شوف TV — Performance Indexes
-- ============================================================

-- Matches
CREATE INDEX idx_matches_league ON public.matches(league_id);
CREATE INDEX idx_matches_start_time ON public.matches(start_time);
CREATE INDEX idx_matches_status ON public.matches(status);
CREATE INDEX idx_matches_home_team ON public.matches(home_team_id);
CREATE INDEX idx_matches_away_team ON public.matches(away_team_id);

-- Standings
CREATE INDEX idx_standings_league ON public.standings(league_id);
CREATE INDEX idx_standings_position ON public.standings(league_id, position);

-- Match Events
CREATE INDEX idx_events_match ON public.match_events(match_id);
CREATE INDEX idx_events_type ON public.match_events(event_type);

-- Match Lineups
CREATE INDEX idx_lineups_match ON public.match_lineups(match_id);

-- Streaming Servers
CREATE INDEX idx_streams_match ON public.streaming_servers(match_id);
CREATE INDEX idx_streams_priority ON public.streaming_servers(match_id, priority);

-- Player Stats
CREATE INDEX idx_player_stats_league ON public.player_stats(league_id);
CREATE INDEX idx_player_stats_goals ON public.player_stats(league_id, goals DESC);
CREATE INDEX idx_player_stats_assists ON public.player_stats(league_id, assists DESC);

-- Teams
CREATE INDEX idx_teams_league ON public.teams(league_id);

-- News
CREATE INDEX idx_news_category ON public.news(category);
CREATE INDEX idx_news_created ON public.news(created_at DESC);
