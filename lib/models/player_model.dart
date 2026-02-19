class Player {
  final String id;
  final String name;
  final int number;
  final String photoUrl;
  final String position; // "GK", "DF", "MF", "FW"
  final bool isCaptain;

  Player({
    required this.id,
    required this.name,
    required this.number,
    required this.photoUrl,
    required this.position,
    this.isCaptain = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['player_name'] ?? json['name'] ?? '',
      number: json['player_number'] ?? json['number'] ?? 0,
      photoUrl: json['photo_url'] ?? '',
      position: json['position'] ?? 'MF',
      isCaptain: json['is_captain'] ?? false,
    );
  }
}
