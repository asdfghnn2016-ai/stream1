import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase service for شوف TV.
/// Handles all database queries, Edge Function calls, and Realtime subscriptions.
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ────────────────────────────────────────────────────
  // AUTH
  // ────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Guest mode: anonymous sign in
  Future<AuthResponse> signInAsGuest() async {
    return await _client.auth.signInAnonymously();
  }

  // ────────────────────────────────────────────────────
  // LEAGUES (LeagueSelectorScreen)
  // ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLeagues() async {
    final response = await _client
        .from('leagues')
        .select()
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  // ────────────────────────────────────────────────────
  // LEAGUE DETAILS (Edge Function — optimized bundle)
  // ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getLeagueDetails(String leagueId) async {
    final response = await _client.functions.invoke(
      'get-league-details',
      body: {'league_id': leagueId},
    );
    return Map<String, dynamic>.from(response.data);
  }

  // ────────────────────────────────────────────────────
  // MATCHES (MatchesScreen)
  // ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMatchesByDate(DateTime date) async {
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();

    final response = await _client
        .from('matches')
        .select(
          '*, home_team:teams!home_team_id(id, name, logo_url), away_team:teams!away_team_id(id, name, logo_url), leagues(name)',
        )
        .gte('start_time', startOfDay)
        .lte('start_time', endOfDay)
        .order('start_time');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getLiveMatches() async {
    final response = await _client
        .from('matches')
        .select(
          '*, home_team:teams!home_team_id(id, name, logo_url), away_team:teams!away_team_id(id, name, logo_url), leagues(name)',
        )
        .eq('status', 'live')
        .order('start_time');
    return List<Map<String, dynamic>>.from(response);
  }

  // ────────────────────────────────────────────────────
  // MATCH DETAILS (Edge Function)
  // ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMatchDetails(String matchId) async {
    final response = await _client.functions.invoke(
      'get-match-details',
      body: {'match_id': matchId},
    );
    return Map<String, dynamic>.from(response.data);
  }

  // ────────────────────────────────────────────────────
  // STREAMING SERVERS (LivePlayerScreen)
  // ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMatchStreams(String matchId) async {
    final response = await _client
        .from('streaming_servers')
        .select()
        .eq('match_id', matchId)
        .order('priority');
    return List<Map<String, dynamic>>.from(response);
  }

  // ────────────────────────────────────────────────────
  // NEWS (NewsScreen)
  // ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNews({
    int limit = 20,
    int offset = 0,
    String? category,
  }) async {
    var query = _client
        .from('news')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    if (category != null) {
      query = _client
          .from('news')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // ────────────────────────────────────────────────────
  // USER PREFERENCES (SettingsScreen)
  // ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (!isAuthenticated) return null;
    final response = await _client
        .from('user_preferences')
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();
    return response;
  }

  Future<void> updateUserPreferences(Map<String, dynamic> data) async {
    if (!isAuthenticated) return;
    data['updated_at'] = DateTime.now().toIso8601String();
    await _client
        .from('user_preferences')
        .update(data)
        .eq('user_id', currentUser!.id);
  }

  Future<void> toggleFavoriteTeam(String teamId) async {
    final prefs = await getUserPreferences();
    if (prefs == null) return;

    final teams = List<String>.from(prefs['favorite_team_ids'] ?? []);
    if (teams.contains(teamId)) {
      teams.remove(teamId);
    } else {
      teams.add(teamId);
    }
    await updateUserPreferences({'favorite_team_ids': teams});
  }

  Future<void> toggleFavoriteLeague(String leagueId) async {
    final prefs = await getUserPreferences();
    if (prefs == null) return;

    final leagues = List<String>.from(prefs['favorite_league_ids'] ?? []);
    if (leagues.contains(leagueId)) {
      leagues.remove(leagueId);
    } else {
      leagues.add(leagueId);
    }
    await updateUserPreferences({'favorite_league_ids': leagues});
  }

  // ────────────────────────────────────────────────────
  // REALTIME SUBSCRIPTIONS
  // ────────────────────────────────────────────────────

  /// Subscribe to live match score updates
  RealtimeChannel subscribeToMatch(
    String matchId,
    void Function(Map<String, dynamic>) onUpdate,
  ) {
    return _client
        .channel('match_$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'matches',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: matchId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Subscribe to live standings changes
  RealtimeChannel subscribeToStandings(
    String leagueId,
    void Function(Map<String, dynamic>) onUpdate,
  ) {
    return _client
        .channel('standings_$leagueId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'standings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'league_id',
            value: leagueId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Subscribe to new match events (goals, cards)
  RealtimeChannel subscribeToMatchEvents(
    String matchId,
    void Function(Map<String, dynamic>) onInsert,
  ) {
    return _client
        .channel('events_$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'match_events',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            onInsert(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  // ────────────────────────────────────────────────────
  // STANDINGS (Direct — fallback if Edge Function not deployed)
  // ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStandings(String leagueId) async {
    final response = await _client
        .from('standings')
        .select('*, teams(name, short_name, logo_url)')
        .eq('league_id', leagueId)
        .order('position');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTopScorers(
    String leagueId, {
    int limit = 20,
  }) async {
    final response = await _client
        .from('player_stats')
        .select('*, teams(name, logo_url)')
        .eq('league_id', leagueId)
        .order('goals', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTopAssists(
    String leagueId, {
    int limit = 20,
  }) async {
    final response = await _client
        .from('player_stats')
        .select('*, teams(name, logo_url)')
        .eq('league_id', leagueId)
        .order('assists', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }
}
