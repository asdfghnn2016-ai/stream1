class StreamingServer {
  final String id;
  final String name; // e.g., "Server 1 (1080p)"
  final String url;
  final String quality; // "1080p", "720p", "Auto"
  final int priority; // 1 is highest
  final bool isBackup;
  final Map<String, String>? headers;

  StreamingServer({
    required this.id,
    required this.name,
    required this.url,
    required this.quality,
    required this.priority,
    this.isBackup = false,
    this.headers,
  });

  factory StreamingServer.fromJson(Map<String, dynamic> json) {
    Map<String, String>? headers;
    if (json['headers'] != null && json['headers'] is Map) {
      headers = Map<String, String>.from(json['headers']);
    }
    return StreamingServer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      quality: json['quality'] ?? '720p',
      priority: json['priority'] ?? 1,
      isBackup: json['is_backup'] ?? false,
      headers: headers,
    );
  }

  // Mock Data
  static List<StreamingServer> getMockServers() {
    return [
      StreamingServer(
        id: '1',
        name: 'سيرفر أساسي (Full HD)',
        url:
            'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', // Public HLS test
        quality: '1080p',
        priority: 1,
      ),
      StreamingServer(
        id: '2',
        name: 'سيرفر احتياطي 1 (HD)',
        url:
            'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        quality: '720p',
        priority: 2,
      ),
      StreamingServer(
        id: '3',
        name: 'سيرفر طوارئ (SD)',
        url:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
        quality: '360p',
        priority: 3,
        isBackup: true,
      ),
    ];
  }
}
