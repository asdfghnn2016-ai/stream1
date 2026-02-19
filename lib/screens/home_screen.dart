import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/matches_provider.dart';
// Re-added import

import '../widgets/hero_carousel.dart';
import 'match_details_screen.dart';
import 'matches_schedule_screen.dart';
import '../widgets/match_card.dart';
import '../widgets/shimmer_loading.dart';
import 'settings_screen.dart';
import 'news_screen.dart';
import 'standings_screen.dart';
import '../widgets/search_overlay.dart'; // Import SearchOverlay

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      // Only show AppBar for Home Tab if needed, or customize per tab
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(
                "شوف TV",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.black,
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    SearchOverlay.show(context);
                  },
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundColor: Color(0xFF16C47F),
                  radius: 16,
                  child: Icon(Icons.person, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 16),
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light,
            )
          : null, // Hide AppBar for other tabs if they have their own
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeTab(key: PageStorageKey('home_tab')),
          MatchesScheduleScreen(key: PageStorageKey('matches_tab')),
          NewsScreen(key: PageStorageKey('news_tab')),
          StandingsScreen(key: PageStorageKey('standings_tab')),
          SettingsScreen(key: PageStorageKey('settings_tab')),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF16C47F),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'المباريات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              label: 'الأخبار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined),
              label: 'الترتيب',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  final bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MatchesProvider>(context, listen: false).fetchHomeData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Basic pagination trigger (though provider currently fetches all)
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      // _loadMoreMatches(); // Implement pagination later
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesProvider = Provider.of<MatchesProvider>(context);

    return matchesProvider.isHomeLoading
        ? Center(child: _buildShimmerList())
        : RefreshIndicator(
            onRefresh: () async {
              await matchesProvider.fetchHomeData();
            },
            color: const Color(0xFF16C47F),
            backgroundColor: Colors.grey[900],
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Hero Section (Featured/Live Matches)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: HeroCarousel(
                      featuredMatches: matchesProvider.liveMatches,
                    ),
                  ),
                ),

                // Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      "المباريات اليوم",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Matches List (Today's Matches)
                matchesProvider.todayMatches.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              "لا توجد مباريات اليوم",
                              style: GoogleFonts.cairo(color: Colors.white54),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final match = matchesProvider.todayMatches[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MatchDetailsScreen(match: match),
                                ),
                              );
                            },
                            child: MatchCard(match: match),
                          );
                        }, childCount: matchesProvider.todayMatches.length),
                      ),

                // Loading Spinner at bottom
                if (_isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF16C47F),
                        ),
                      ),
                    ),
                  ),

                // Bottom padding for fab area
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerLoading(),
    );
  }
}
