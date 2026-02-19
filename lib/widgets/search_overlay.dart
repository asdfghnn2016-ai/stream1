import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SearchOverlay(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  String _query = '';
  final List<String> _recentSearches = [
    'الهلال',
    'النصر',
    'الدوري السعودي',
    'كريستيانو',
  ]; // Mock defaults

  @override
  void initState() {
    super.initState();
    // Auto-focus after transition
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _isLoading = value.isNotEmpty; // Simulate loading
    });

    if (value.isNotEmpty) {
      // simulate debounce
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _query == value) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Important for overlay effect
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF0B0F1A), // Match AppBar
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: "ابحث عن فريق، مباراة، أو خبر...",
                        hintStyle: GoogleFonts.cairo(
                          color: Colors.white38,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  else
                    const Icon(Icons.search, color: Color(0xFF16C47F)),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: const Color(0xFF000000).withValues(alpha: 0.9),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16C47F)),
      );
    }

    if (_query.isEmpty) {
      return _buildRecentSearches();
    }

    return _buildSearchResults();
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          "عمليات البحث الأخيرة",
          style: GoogleFonts.cairo(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          direction: Axis.horizontal,
          textDirection: TextDirection.rtl,
          children: _recentSearches.map((search) {
            return ActionChip(
              backgroundColor: const Color(0xFF1E2433),
              label: Text(
                search,
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              onPressed: () {
                _searchController.text = search;
                _onSearchChanged(search);
                _focusNode.requestFocus();
              },
              avatar: const Icon(Icons.history, size: 16, color: Colors.grey),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    // Mock Results
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle("المباريات"),
        // Mock Match Result
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2433),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الهلال 2 - 1 النصر",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "منتهي",
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionTitle("الفرق"),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text("H"),
          ),
          title: Text("الهلال", style: GoogleFonts.cairo(color: Colors.white)),
          subtitle: Text(
            "الدوري السعودي",
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
          ),
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 24),
        _buildSectionTitle("الأخبار"),
        ListTile(
          leading: Container(width: 60, height: 40, color: Colors.grey[800]),
          title: Text(
            "نتيجة مباراة الكلاسيكو...",
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          subtitle: Text(
            "منذ ساعة",
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: const Color(0xFF16C47F),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}
