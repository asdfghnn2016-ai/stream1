import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/league_model.dart';
import '../widgets/standings/league_table_tab.dart';
import '../widgets/standings/league_matches_tab.dart';
import '../widgets/standings/top_scorers_tab.dart';
import '../widgets/standings/advanced_analytics_tab.dart';

class LeagueDetailsScreen extends StatefulWidget {
  final League league;

  const LeagueDetailsScreen({super.key, required this.league});

  @override
  State<LeagueDetailsScreen> createState() => _LeagueDetailsScreenState();
}

class _LeagueDetailsScreenState extends State<LeagueDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1A),
        title: Text(
          widget.league.name,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF16C47F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF16C47F),
          labelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: "المباريات"),
            Tab(text: "الفرق"),
            Tab(text: "الهدافون"),
            Tab(text: "الصنّاع"),
            Tab(text: "الإحصائيات"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const LeagueMatchesTab(),
          const LeagueTableTab(),
          const TopScorersTab(isAssists: false),
          const TopScorersTab(isAssists: true),
          const AdvancedAnalyticsTab(),
        ],
      ),
    );
  }
}
