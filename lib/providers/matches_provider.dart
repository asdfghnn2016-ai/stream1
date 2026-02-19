import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/supabase_service.dart';

class MatchesProvider with ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  // Schedule Screen State
  List<Match> _matches = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  // Home Screen State
  List<Match> _liveMatches = [];
  List<Match> _todayMatches = [];
  bool _isHomeLoading = false;

  // Getters
  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  List<Match> get liveMatches => _liveMatches;
  List<Match> get todayMatches => _todayMatches;
  bool get isHomeLoading => _isHomeLoading;

  // Fetch matches for a specific date (Schedule Screen)
  Future<void> fetchMatchesForDate(DateTime date) async {
    _isLoading = true;
    _selectedDate = date;
    notifyListeners();

    try {
      final data = await _service.getMatchesByDate(date);
      _matches = data.map((json) => Match.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching matches for date: $e');
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Home Screen Data (Live + Today)
  Future<void> fetchHomeData() async {
    _isHomeLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Live Matches
      final liveData = await _service.getLiveMatches();
      _liveMatches = liveData.map((json) => Match.fromJson(json)).toList();

      // 2. Fetch Today's Matches
      final todayData = await _service.getMatchesByDate(DateTime.now());
      _todayMatches = todayData.map((json) => Match.fromJson(json)).toList();

      // Fallback logic for featured: if no live matches, show top upcoming
      if (_liveMatches.isEmpty && _todayMatches.isNotEmpty) {
        _liveMatches = _todayMatches.take(5).toList();
      }
    } catch (e) {
      print('Error fetching home data: $e');
      _liveMatches = [];
      _todayMatches = [];
    } finally {
      _isHomeLoading = false;
      notifyListeners();
    }
  }

  // Real-time Subscription (Placeholder for now)
  void subscribeToLiveUpdates() {
    // In a future update, we can implement real-time listeners here
    // _service.subscribeToMatch(matchId, (data) { ... });
    fetchHomeData(); // Initial fetch
  }
}
