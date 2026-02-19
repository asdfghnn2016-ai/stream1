import 'player_model.dart';
import 'team_model.dart';

class Match {
  final String id;
  final Team homeTeam;
  final Team awayTeam;
  final DateTime matchTime;
  final String league;
  final bool isLive;
  final String? score;
  final String venue;
  final String referee;
  final String channel;
  final String commentator;
  final String round;
  final String status; // "Live", "Finished", "Upcoming"
  final List<Player> homeLineup;
  final List<Player> awayLineup;
  final String homeFormation;
  final String awayFormation;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchTime,
    required this.league,
    this.isLive = false,
    this.score,
    required this.venue,
    required this.referee,
    required this.channel,
    required this.commentator,
    required this.round,
    required this.status,
    required this.homeLineup,
    required this.awayLineup,
    required this.homeFormation,
    required this.awayFormation,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    final homeTeamData = json['home_team'] as Map<String, dynamic>?;
    final awayTeamData = json['away_team'] as Map<String, dynamic>?;
    final leagueData = json['leagues'] as Map<String, dynamic>?;
    final status = json['status'] ?? 'upcoming';
    final homeScore = json['home_score'] ?? 0;
    final awayScore = json['away_score'] ?? 0;

    return Match(
      id: json['id'] ?? '',
      homeTeam: homeTeamData != null
          ? Team.fromJson(homeTeamData)
          : Team(id: '', name: '???', logoUrl: ''),
      awayTeam: awayTeamData != null
          ? Team.fromJson(awayTeamData)
          : Team(id: '', name: '???', logoUrl: ''),
      matchTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      league: leagueData?['name'] ?? json['league'] ?? '',
      isLive: status == 'live',
      score: status != 'upcoming' ? '$homeScore - $awayScore' : null,
      venue: json['venue'] ?? '',
      referee: json['referee'] ?? '',
      channel: json['channel'] ?? '',
      commentator: json['commentator'] ?? '',
      round: json['round'] ?? '',
      status: status == 'live'
          ? 'Live'
          : status == 'finished'
          ? 'Finished'
          : 'Upcoming',
      homeLineup: [],
      awayLineup: [],
      homeFormation: json['home_formation'] ?? '4-3-3',
      awayFormation: json['away_formation'] ?? '4-3-3',
    );
  }
}
