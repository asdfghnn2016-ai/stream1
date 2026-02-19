import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/league_model.dart';
import '../services/supabase_service.dart';
import 'league_details_screen.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  List<League> _leagues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    try {
      final data = await SupabaseService.instance.getLeagues();
      if (mounted) {
        setState(() {
          _leagues = data.map((json) => League.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to mock data
      if (mounted) {
        setState(() {
          _leagues = League.getMockLeagues();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLeague(League league) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeagueDetailsScreen(league: league),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        title: Text(
          "الترتيب",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0B0F1A),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality (Optional)
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF16C47F)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Search Bar (Optional Visual)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2433),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        "ابحث عن بطولة",
                        style: GoogleFonts.cairo(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section Title
                Text(
                  "البطولات المفضلة",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // League List
                ..._leagues.map((league) => _buildLeagueCard(league)),
              ],
            ),
    );
  }

  Widget _buildLeagueCard(League league) {
    return GestureDetector(
      onTap: () => _navigateToLeague(league),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2433),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: league.isFavorite
                ? const Color(0xFF16C47F).withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // League Logo (Placeholder)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: Colors.white70),
            ),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    league.name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    league.region,
                    style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Favorite Star
            Icon(
              Icons.star,
              color: league.isFavorite ? const Color(0xFFFFC107) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
