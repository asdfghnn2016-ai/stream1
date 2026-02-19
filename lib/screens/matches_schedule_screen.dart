import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../widgets/calendar_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../providers/matches_provider.dart';
import 'match_details_screen.dart';

class MatchesScheduleScreen extends StatefulWidget {
  const MatchesScheduleScreen({super.key});

  @override
  State<MatchesScheduleScreen> createState() => _MatchesScheduleScreenState();
}

class _MatchesScheduleScreenState extends State<MatchesScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MatchesProvider>(
        context,
        listen: false,
      ).fetchMatchesForDate(_selectedDate);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    Provider.of<MatchesProvider>(
      context,
      listen: false,
    ).fetchMatchesForDate(date);
  }

  void _showCalendar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CalendarBottomSheet(
        selectedDate: _selectedDate,
        onDateSelected: _onDateSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider and settings
    final matchesProvider = Provider.of<MatchesProvider>(context);
    final settings = Provider.of<SettingsController>(context);

    // Process matches from provider
    Map<String, List<Match>> currentMatches = _getProcessedMatches(
      matchesProvider.matches,
      settings,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "المباريات",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).iconTheme.color ?? Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).iconTheme.color ?? Colors.white,
            ),
            onPressed: _showCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: matchesProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF16C47F)),
                  )
                : currentMatches.isEmpty
                ? Center(
                    child: Text(
                      "لا توجد مباريات لهذا اليوم",
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 16),
                    itemCount: currentMatches.keys.length,
                    itemBuilder: (context, index) {
                      String league = currentMatches.keys.elementAt(index);
                      List<Match> matches = currentMatches[league]!;
                      return _buildLeagueSection(league, matches);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Match>> _getProcessedMatches(
    List<Match> allMatches,
    SettingsController settings,
  ) {
    if (allMatches.isEmpty) return {};

    String sortOrder = settings.matchSortOrder;
    List<Match> filtered = List.from(allMatches);

    // Filter
    if (sortOrder == 'important') {
      filtered = filtered
          .where((m) => m.league == 'دوري أبطال أوروبا')
          .toList();
    } else if (sortOrder == 'favorite') {
      // Logic for favorites would need actual IDs, usually this is complex
      // For now, keeping simple or removing if not implemented
      filtered = filtered;
    }

    // Sort/Group
    Map<String, List<Match>> grouped = {};
    if (sortOrder == 'time') {
      filtered.sort((a, b) => a.matchTime.compareTo(b.matchTime));
      if (filtered.isNotEmpty) {
        grouped['كل المباريات'] = filtered;
      }
    } else {
      for (var match in filtered) {
        if (!grouped.containsKey(match.league)) {
          grouped[match.league] = [];
        }
        grouped[match.league]!.add(match);
      }
    }
    return grouped;
  }

  Widget _buildDateSelector() {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F1A),
        border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 14, // 2 weeks
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 2));
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month;

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF16C47F)
                    : const Color(0xFF1E2433),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF16C47F).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white10,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'ar').format(date),
                    style: GoogleFonts.cairo(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeagueSection(String league, List<Match> matches) {
    return Column(
      children: [
        // League Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF16C47F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                league,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
            ],
          ),
        ),

        // Matches
        ...matches.map((match) => _buildGlassMatchCard(match)),
      ],
    );
  }

  Widget _buildGlassMatchCard(Match match) {
    final timeFormat = DateFormat('h:mm a');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailsScreen(match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 100, // Fixed height for consistency
        decoration: BoxDecoration(
          color: const Color(
            0xFF1E2433,
          ).withValues(alpha: 0.8), // Glass-like background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Home Team
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTeamLogo(match.homeTeam.logoUrl),
                  const SizedBox(height: 6),
                  Text(
                    match.homeTeam.name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Score / Time
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (match.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        "LIVE",
                        style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        timeFormat.format(match.matchTime),
                        style: GoogleFonts.cairo(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  Text(
                    match.isLive ? (match.score ?? "0 - 0") : "VS",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Away Team
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTeamLogo(match.awayTeam.logoUrl),
                  const SizedBox(height: 6),
                  Text(
                    match.awayTeam.name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String url) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => const SizedBox(),
        errorWidget: (context, url, err) =>
            const Icon(Icons.shield, color: Colors.grey, size: 20),
      ),
    );
  }
}
