import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';
import '../services/supabase_service.dart';

import '../widgets/calendar_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import 'match_details_screen.dart';

class MatchesScheduleScreen extends StatefulWidget {
  const MatchesScheduleScreen({super.key});

  @override
  State<MatchesScheduleScreen> createState() => _MatchesScheduleScreenState();
}

class _MatchesScheduleScreenState extends State<MatchesScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Match> _allMatches = []; // Store raw list

  // Grouped matches for display
  final Map<String, List<Match>> _displayMatches = {};

  @override
  void initState() {
    super.initState();
    _loadMatchesForDate();
  }

  Future<void> _loadMatchesForDate() async {
    try {
      final data = await SupabaseService.instance.getMatchesByDate(
        _selectedDate,
      );
      _allMatches = data.map((json) => Match.fromJson(json)).toList();
    } catch (e) {
      // Fallback to mock data
      _allMatches = List.generate(10, (index) {
        return Match(
          id: 's_$index',
          homeTeam: Team(
            id: 'h$index',
            name: 'Home Team $index',
            logoUrl: 'https://placeholder.com/logo.png',
          ),
          awayTeam: Team(
            id: 'a$index',
            name: 'Away Team $index',
            logoUrl: 'https://placeholder.com/logo.png',
          ),
          matchTime: _selectedDate.add(Duration(hours: 18 + index)),
          league: index < 3
              ? 'دوري أبطال أوروبا'
              : (index < 6 ? 'الدوري الإنجليزي' : 'الدوري السعودي'),
          isLive: index == 0,
          score: index == 0 ? '1 - 1' : null,
          venue: 'Stadium $index',
          referee: 'Referee $index',
          channel: 'BeIN Sports',
          commentator: 'Commentator $index',
          round: 'Group Stage',
          status: index == 0 ? 'Live' : 'Upcoming',
          homeLineup: [],
          awayLineup: [],
          homeFormation: '4-3-3',
          awayFormation: '4-4-2',
        );
      });
    }

    if (mounted) {
      _applyFilters(Provider.of<SettingsController>(context, listen: false));
      setState(() {});
    }
  }

  void _applyFilters(SettingsController settings) {
    String sortOrder = settings.matchSortOrder;
    List<Match> filtered = List.from(_allMatches);

    // 1. Filter
    if (sortOrder == 'important') {
      // Mock importance: Only Champions League
      filtered = filtered
          .where((m) => m.league == 'دوري أبطال أوروبا')
          .toList();
    } else if (sortOrder == 'favorite') {
      // Mock favorite: Even indices
      filtered = filtered
          .where((m) => int.parse(m.id.split('_')[1]) % 2 == 0)
          .toList();
    }

    // 2. Sort/Group
    _displayMatches.clear();
    if (sortOrder == 'time') {
      filtered.sort((a, b) => a.matchTime.compareTo(b.matchTime));
      if (filtered.isNotEmpty) {
        _displayMatches['كل المباريات'] = filtered;
      }
    } else {
      // Default: By Tournament (already broadly sorted by ID structure, but let's group)
      for (var match in filtered) {
        if (!_displayMatches.containsKey(match.league)) {
          _displayMatches[match.league] = [];
        }
        _displayMatches[match.league]!.add(match);
      }
    }
    setState(() {});
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadMatchesForDate();
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
    // Listen to settings changes
    final settings = Provider.of<SettingsController>(context);

    // Re-apply filters when settings change (efficiently)
    // Note: This might loop if not careful, but since build is called on notifyListeners,
    // and _applyFilters calls setState, we should be careful.
    // Better strategy: Just recalculate display map in build or use a Memoized approach.
    // For simplicity in this fix, I will recalculate logic here without setState loops,
    // or better, extract grouping logic to a helper that returns the map.

    Map<String, List<Match>> currentMatches = _getProcessedMatches(settings);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use Theme
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
            child: ListView.builder(
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

  Map<String, List<Match>> _getProcessedMatches(SettingsController settings) {
    if (_allMatches.isEmpty) return {};

    String sortOrder = settings.matchSortOrder;
    List<Match> filtered = List.from(_allMatches);

    // Filter
    if (sortOrder == 'important') {
      filtered = filtered
          .where((m) => m.league == 'دوري أبطال أوروبا')
          .toList();
    } else if (sortOrder == 'favorite') {
      filtered = filtered
          .where((m) => int.parse(m.id.split('_')[1]) % 2 == 0)
          .toList();
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
                          color: const Color(0xFF16C47F).withOpacity(0.4),
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
          ).withOpacity(0.8), // Glass-like background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
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
        color: Colors.white.withOpacity(0.05),
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
