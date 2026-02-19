import 'package:flutter/material.dart';
import '../../models/match_model.dart';
import '../../models/team_model.dart'; // Needed for mock generation if separate
import '../match_card.dart'; // Reuse existing match card

class LeagueMatchesTab extends StatefulWidget {
  const LeagueMatchesTab({super.key});

  @override
  State<LeagueMatchesTab> createState() => _LeagueMatchesTabState();
}

class _LeagueMatchesTabState extends State<LeagueMatchesTab> {
  List<Match> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    if (mounted) {
      setState(() {
        _matches = _generateMockMatches();
        _isLoading = false;
      });
    }
  }

  // Helper to generate mock matches for this league
  List<Match> _generateMockMatches() {
    final now = DateTime.now();
    return List.generate(10, (index) {
      return Match(
        id: 'lm_$index',
        homeTeam: Team(id: 'h$index', name: 'Team A $index', logoUrl: ''),
        awayTeam: Team(id: 'a$index', name: 'Team B $index', logoUrl: ''),
        matchTime: now.add(Duration(days: index, hours: 20)),
        league: "دوري روشن",
        isLive: index == 0,
        status: index == 0 ? "Live" : "Upcoming",
        score: index == 0 ? "1 - 0" : null,
        venue: "King Saud University Stadium",
        referee: "Szymon Marciniak",
        channel: "SSC 1",
        commentator: "Fahd Al Otaibi",
        round: "Round ${index + 5}",
        homeFormation: "4-2-3-1",
        awayFormation: "4-3-3",
        homeLineup: [],
        awayLineup: [], // Empty for list view
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16C47F)),
      );
    }

    // Group by Date (Simplified for now, just list)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MatchCard(match: _matches[index]),
        );
      },
    );
  }
}
