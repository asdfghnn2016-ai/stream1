import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/league_model.dart';
import 'league_details_screen.dart';

class LeagueSelectorScreen extends StatefulWidget {
  const LeagueSelectorScreen({super.key});

  @override
  State<LeagueSelectorScreen> createState() => _LeagueSelectorScreenState();
}

class _LeagueSelectorScreenState extends State<LeagueSelectorScreen> {
  List<League> _allLeagues = [];
  List<League> _filteredLeagues = [];

  @override
  void initState() {
    super.initState();
    _allLeagues = League.getMockLeagues();
    _filteredLeagues = _allLeagues;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLeagues = _allLeagues;
      } else {
        _filteredLeagues = _allLeagues
            .where(
              (league) =>
                  league.name.contains(query) || league.region.contains(query),
            )
            .toList();
      }
    });
  }

  void _toggleFavorite(League league) {
    setState(() {
      league.isFavorite = !league.isFavorite;
    });
  }

  void _navigateToDetails(League league) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeagueDetailsScreen(league: league),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Separate Favorites from others
    final favorites = _filteredLeagues.where((l) => l.isFavorite).toList();
    final others = _filteredLeagues.where((l) => !l.isFavorite).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        title: Text(
          "البطولات",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2433),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: Colors.grey),
                hintText: "ابحث عن بطولة...",
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (favorites.isNotEmpty) ...[
                  _buildSectionTitle("المفضلة"),
                  ...favorites.map((l) => _buildLeagueTile(l)),
                  const SizedBox(height: 24),
                ],

                if (others.isNotEmpty) ...[
                  _buildSectionTitle("جميع البطولات"),
                  ...others.map((l) => _buildLeagueTile(l)),
                ],
              ],
            ),
          ),
        ],
      ),
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
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLeagueTile(League league) {
    return GestureDetector(
      onTap: () => _navigateToDetails(league),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2433),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Logo Placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Name & Region
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    league.name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    league.region,
                    style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Star
            IconButton(
              icon: Icon(
                league.isFavorite ? Icons.star : Icons.star_border,
                color: league.isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(league),
            ),
          ],
        ),
      ),
    );
  }
}
