import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/match_model.dart';
import '../models/team_model.dart';
import '../models/player_model.dart';
import '../services/supabase_service.dart';
import '../widgets/hero_carousel.dart';
import 'match_details_screen.dart';
import 'matches_schedule_screen.dart';
import '../widgets/match_card.dart';
import '../widgets/shimmer_loading.dart';
import 'settings_screen.dart';
import 'news_screen.dart';
import 'standings_screen.dart';
import '../widgets/search_overlay.dart'; // Import SearchOverlay
import 'dart:async';

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
      backgroundColor: Colors.black,
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
          : null,
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
              color: Colors.white.withOpacity(0.05),
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
              icon: Icon(Icons.sports_soccer),
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
              icon: Icon(Icons.person_outline),
              label: 'حسابي',
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

  // Data State
  List<Match> _matches = [];
  List<Match> _featuredMatches = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreMatches();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final api = SupabaseService.instance;

      // Fetch live matches for carousel and today's matches
      final liveData = await api.getLiveMatches();
      final todayData = await api.getMatchesByDate(DateTime.now());

      if (mounted) {
        setState(() {
          _featuredMatches = liveData
              .map((json) => Match.fromJson(json))
              .toList();
          _matches = todayData.map((json) => Match.fromJson(json)).toList();

          // If no featured matches from Supabase, use first 3 from today
          if (_featuredMatches.isEmpty && _matches.isNotEmpty) {
            _featuredMatches = _matches.take(3).toList();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to mock data
      if (mounted) {
        setState(() {
          _featuredMatches = _generateMockMatches(3, upcoming: false);
          _matches = _generateMockMatches(10);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreMatches() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    // For now, no pagination from Supabase — just end the loading
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<Match> _generateMockMatches(int count, {bool upcoming = true}) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      final isLive = !upcoming || (index % 4 == 0); // Mixed live/upcoming

      return Match(
        id: 'm_$index',
        homeTeam: Team(
          id: 'h_$index',
          name: 'Home Team $index',
          logoUrl: 'https://placeholder.com/logo.png',
        ),
        awayTeam: Team(
          id: 'a_$index',
          name: 'Away Team $index',
          logoUrl: 'https://placeholder.com/logo.png',
        ),
        matchTime: now.add(Duration(hours: index * 2)),
        league: index % 2 == 0 ? 'Premier League' : 'La Liga',
        isLive: isLive,
        score: isLive ? '1 - 0' : null,
        venue: 'Stadium $index',
        referee: 'Referee $index',
        channel: 'Channel $index',
        commentator: 'Commentator $index',
        round: 'Round $index',
        status: isLive ? 'Live' : 'Upcoming',
        homeLineup: List.generate(
          11,
          (pIndex) => Player(
            id: 'h_p$pIndex',
            name: pIndex == 0 ? 'GK Home' : 'Player $pIndex',
            number: pIndex == 0 ? 1 : pIndex + 1,
            photoUrl: '',
            position: pIndex == 0 ? 'GK' : 'PL',
            isCaptain: pIndex == 10,
          ),
        ),
        awayLineup: List.generate(
          11,
          (pIndex) => Player(
            id: 'a_p$pIndex',
            name: pIndex == 0 ? 'GK Away' : 'Player $pIndex',
            number: pIndex == 0 ? 1 : pIndex + 1,
            photoUrl: '',
            position: pIndex == 0 ? 'GK' : 'PL',
            isCaptain: pIndex == 10,
          ),
        ),
        homeFormation: '4-4-2',
        awayFormation: '4-3-3',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: _buildShimmerList())
        : RefreshIndicator(
            onRefresh: _loadInitialData,
            color: const Color(0xFF16C47F),
            backgroundColor: Colors.grey[900],
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Hero Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: HeroCarousel(featuredMatches: _featuredMatches),
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

                // Matches List
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MatchDetailsScreen(match: _matches[index]),
                          ),
                        );
                      },
                      child: MatchCard(match: _matches[index]),
                    );
                  }, childCount: _matches.length),
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
