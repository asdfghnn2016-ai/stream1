import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/news_model.dart';
import '../services/supabase_service.dart';
import '../widgets/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // Categories
  final List<String> _categories = [
    "الكل",
    "عاجل",
    "انتقال",
    "إصابة",
    "ملخص",
    "تحديثات",
  ];
  String _selectedCategory = "الكل";

  // Data
  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _filteredArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final data = await SupabaseService.instance.getNews(limit: 50);
      if (mounted) {
        setState(() {
          _allArticles = data
              .map((json) => NewsArticle.fromJson(json))
              .toList();
          _filterNews();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to mock data
      if (mounted) {
        setState(() {
          _allArticles = NewsArticle.getMockArticles();
          _filterNews();
          _isLoading = false;
        });
      }
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterNews();
    });
  }

  void _filterNews() {
    if (_selectedCategory == "الكل") {
      _filteredArticles = _allArticles;
    } else {
      _filteredArticles = _allArticles
          .where((a) => a.category == _selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A), // Premium Dark
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF0B0F1A),
            floating: true,
            snap: true,
            title: Text(
              "آخر الأخبار",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildCategoryList(),
            ),
          ),

          // 2. Content
          _isLoading
              ? SliverFillRemaining(child: _buildShimmerList())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  sliver: _filteredArticles.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Text(
                              "لا توجد أخبار في هذا القسم",
                              style: GoogleFonts.cairo(color: Colors.white54),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return NewsCard(
                              article: _filteredArticles[index],
                              onTap: () {
                                // Navigate to details (future scope)
                              },
                            );
                          }, childCount: _filteredArticles.length),
                        ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _categories[index] == _selectedCategory;
          return ActionChip(
            label: Text(_categories[index]),
            labelStyle: GoogleFonts.cairo(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: isSelected
                ? const Color(0xFF16C47F)
                : const Color(0xFF1E2433),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => _onCategorySelected(_categories[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Column(
          children: [
            Container(height: 180, color: Colors.white, width: double.infinity),
            const SizedBox(height: 16),
            Container(height: 10, color: Colors.white, width: 200),
          ],
        ),
      ),
    );
  }
}
