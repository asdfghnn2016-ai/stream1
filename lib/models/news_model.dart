class NewsArticle {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category; // "Breaking", "Transfer", "Match", "General"
  final DateTime timestamp;
  final String url; // For sharing/webview

  NewsArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
    required this.timestamp,
    required this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'عام',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      url: json['url'] ?? '',
    );
  }

  // Mock Factory
  static List<NewsArticle> getMockArticles() {
    return [
      NewsArticle(
        id: '1',
        title: "رسميًا: الهلال يوقع مع النجم العالمي",
        subtitle:
            "صفقة مدوية تهز الدوري السعودي للمحترفين في الميركاتو الشتوي.",
        imageUrl:
            "https://images.unsplash.com/photo-1522778119026-d647f0565c6a?auto=format&fit=crop&q=80&w=1000",
        category: "انتقال",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        url: "https://shoof.tv/news/1",
      ),
      NewsArticle(
        id: '2',
        title: "ملخص مباراة النصر والاتحاد",
        subtitle: "كلاسيكو مثير ينتهي بالتعادل الإيجابي وأهداف مذهلة.",
        imageUrl:
            "https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&q=80&w=1000",
        category: "ملخص",
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        url: "https://shoof.tv/news/2",
      ),
      NewsArticle(
        id: '3',
        title: "إصابة قوية تبعد نجم الأهلي",
        subtitle: "التقارير الطبية تؤكد غياب اللاعب عن الملاعب لمدة شهر.",
        imageUrl:
            "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&q=80&w=1000",
        category: "إصابة",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        url: "https://shoof.tv/news/3",
      ),
      NewsArticle(
        id: '4',
        title: "ترتيب الدوري بعد الجولة 25",
        subtitle: "اشتعلت المنافسة على اللقب وصراع الهبوط يشتد.",
        imageUrl:
            "https://images.unsplash.com/photo-1577416412292-7611e37a29e2?auto=format&fit=crop&q=80&w=1000",
        category: "تحديثات",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        url: "https://shoof.tv/news/4",
      ),
      NewsArticle(
        id: '5',
        title: "تصريحات نارية من مدرب المنتخب",
        subtitle: "المدرب يكشف أسباب استبعاد بعض النجوم من القائمة.",
        imageUrl:
            "https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&q=80&w=1000",
        category: "عاجل",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        url: "https://shoof.tv/news/5",
      ),
    ];
  }
}
