class League {
  final String id;
  final String name;
  final String logoUrl;
  final String region; // e.g., "Saudi Arabia", "England", "Europe"
  bool isFavorite;

  League({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.region,
    this.isFavorite = false,
  });

  factory League.fromJson(
    Map<String, dynamic> json, {
    List<String> favoriteIds = const [],
  }) {
    final id = json['id'] ?? '';
    return League(
      id: id,
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      region: json['country'] ?? '',
      isFavorite: favoriteIds.contains(id),
    );
  }

  static List<League> getMockLeagues() {
    return [
      League(
        id: '1',
        name: 'دوري روشن السعودي',
        logoUrl: '',
        region: 'السعودية',
        isFavorite: true,
      ),
      League(
        id: '2',
        name: 'الدوري الإنجليزي الممتاز',
        logoUrl: '',
        region: 'إنجلترا',
        isFavorite: true,
      ),
      League(
        id: '3',
        name: 'لاليغا',
        logoUrl: '',
        region: 'إسبانيا',
        isFavorite: false,
      ),
      League(
        id: '4',
        name: 'دوري أبطال أوروبا',
        logoUrl: '',
        region: 'أوروبا',
        isFavorite: true,
      ),
      League(
        id: '5',
        name: 'الدوري الإيطالي',
        logoUrl: '',
        region: 'إيطاليا',
        isFavorite: false,
      ),
      League(
        id: '6',
        name: 'الدوري الألماني',
        logoUrl: '',
        region: 'ألمانيا',
        isFavorite: false,
      ),
      League(
        id: '7',
        name: 'الدوري الفرنسي',
        logoUrl: '',
        region: 'فرنسا',
        isFavorite: false,
      ),
      League(
        id: '8',
        name: 'دوري يلو',
        logoUrl: '',
        region: 'السعودية',
        isFavorite: false,
      ),
    ];
  }
}
