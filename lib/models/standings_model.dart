class LeagueTableEntry {
  final int rank;
  final String teamName;
  final String logoUrl;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final String trend; // "up", "down", "same"

  // Advanced Stats
  final List<String> form; // ["W", "D", "L", "W", "W"]
  final double xG;
  final double possession;
  final double passingAccuracy;
  final DateTime lastUpdated;

  int get goalDifference => goalsFor - goalsAgainst;

  LeagueTableEntry({
    required this.rank,
    required this.teamName,
    required this.logoUrl,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    this.trend = 'same',
    this.form = const [],
    this.xG = 0.0,
    this.possession = 0.0,
    this.passingAccuracy = 0.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  LeagueTableEntry copyWith({
    int? rank,
    int? points,
    int? goalsFor,
    int? goalsAgainst,
    String? trend,
    DateTime? lastUpdated,
  }) {
    return LeagueTableEntry(
      rank: rank ?? this.rank,
      teamName: teamName,
      logoUrl: logoUrl,
      played: played,
      won: won,
      drawn: drawn,
      lost: lost,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      points: points ?? this.points,
      trend: trend ?? this.trend,
      form: form,
      xG: xG,
      possession: possession,
      passingAccuracy: passingAccuracy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static List<LeagueTableEntry> getMockTable() {
    return [
      LeagueTableEntry(
        rank: 1,
        teamName: "الهلال",
        logoUrl: "",
        played: 25,
        won: 23,
        drawn: 2,
        lost: 0,
        goalsFor: 70,
        goalsAgainst: 12,
        points: 71,
        trend: "same",
        form: ["W", "W", "W", "W", "W"],
        xG: 2.45,
        possession: 62.5,
        passingAccuracy: 88.2,
      ),
      LeagueTableEntry(
        rank: 2,
        teamName: "النصر",
        logoUrl: "",
        played: 25,
        won: 20,
        drawn: 3,
        lost: 2,
        goalsFor: 65,
        goalsAgainst: 25,
        points: 63,
        trend: "up",
        form: ["W", "W", "D", "W", "W"],
        xG: 2.15,
        possession: 58.1,
        passingAccuracy: 86.5,
      ),
      LeagueTableEntry(
        rank: 3,
        teamName: "الأهلي",
        logoUrl: "",
        played: 25,
        won: 15,
        drawn: 5,
        lost: 5,
        goalsFor: 45,
        goalsAgainst: 20,
        points: 50,
        trend: "down",
        form: ["L", "D", "W", "W", "D"],
        xG: 1.85,
        possession: 55.4,
        passingAccuracy: 84.1,
      ),
      LeagueTableEntry(
        rank: 4,
        teamName: "الاتحاد",
        logoUrl: "",
        played: 25,
        won: 14,
        drawn: 6,
        lost: 5,
        goalsFor: 40,
        goalsAgainst: 22,
        points: 48,
        trend: "same",
        form: ["W", "L", "W", "D", "W"],
        xG: 1.72,
        possession: 51.2,
        passingAccuracy: 82.8,
      ),
      LeagueTableEntry(
        rank: 5,
        teamName: "التعاون",
        logoUrl: "",
        played: 25,
        won: 12,
        drawn: 8,
        lost: 5,
        goalsFor: 38,
        goalsAgainst: 28,
        points: 44,
        trend: "up",
        form: ["W", "W", "D", "L", "D"],
        xG: 1.45,
        possession: 48.5,
        passingAccuracy: 79.5,
      ),
    ];
  }
}

class PlayerStats {
  final int rank;
  final String name;
  final String teamName;
  final String photoUrl;
  final int goals;
  final int assists;

  int get contributions => goals + assists;

  PlayerStats({
    required this.rank,
    required this.name,
    required this.teamName,
    required this.photoUrl,
    required this.goals,
    required this.assists,
  });

  static List<PlayerStats> getMockScorers() {
    return [
      PlayerStats(
        rank: 1,
        name: "كريستيانو رونالدو",
        teamName: "النصر",
        photoUrl: "",
        goals: 28,
        assists: 9,
      ),
      PlayerStats(
        rank: 2,
        name: "ميتروفيتش",
        teamName: "الهلال",
        photoUrl: "",
        goals: 22,
        assists: 5,
      ),
      PlayerStats(
        rank: 3,
        name: "عبدالرزاق حمدالله",
        teamName: "الاتحاد",
        photoUrl: "",
        goals: 18,
        assists: 3,
      ),
    ];
  }

  static List<PlayerStats> getMockContributors() {
    return [
      PlayerStats(
        rank: 1,
        name: "كريستيانو رونالدو",
        teamName: "النصر",
        photoUrl: "",
        goals: 28,
        assists: 9,
      ), // 37
      PlayerStats(
        rank: 2,
        name: "سالم الدوسري",
        teamName: "الهلال",
        photoUrl: "",
        goals: 12,
        assists: 15,
      ), // 27
      PlayerStats(
        rank: 3,
        name: "رياض محرز",
        teamName: "الأهلي",
        photoUrl: "",
        goals: 9,
        assists: 13,
      ), // 22
    ];
  }
}
