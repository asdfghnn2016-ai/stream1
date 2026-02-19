import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/standings_model.dart';
import 'team_comparison_sheet.dart';

class LeagueTableTab extends StatefulWidget {
  const LeagueTableTab({super.key});

  @override
  State<LeagueTableTab> createState() => _LeagueTableTabState();
}

class _LeagueTableTabState extends State<LeagueTableTab> {
  List<LeagueTableEntry> _table = [];
  bool _isLoading = true;
  Timer? _liveTimer;
  bool _isLiveUpdateActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _table = LeagueTableEntry.getMockTable();
        _isLoading = false;
        _startLiveSimulation();
      });
    }
  }

  void _startLiveSimulation() {
    // Simulate a goal every 8 seconds affecting the table
    _liveTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      setState(() {
        _isLiveUpdateActive = true;
        // Randomly pick a team to "score" and update points
        final randomIndex = DateTime.now().second % _table.length;
        var team = _table[randomIndex];
        // Simulate gaining 3 points temporarily or similar logic
        // For simplicity, we just increment points to trigger re-sort/anim

        // In a real app, we would fetch fresh data. Here we mock a change.
        final newPoints =
            team.points +
            (DateTime.now().second % 2 == 0 ? 1 : 0); // Randomly add point

        if (newPoints != team.points) {
          _table[randomIndex] = team.copyWith(
            points: newPoints,
            lastUpdated: DateTime.now(),
            trend: "up", // Simplified trend logic
          );

          // Re-sort
          _table.sort((a, b) => b.points.compareTo(a.points));

          // Re-assign ranks
          for (int i = 0; i < _table.length; i++) {
            _table[i] = _table[i].copyWith(rank: i + 1);
          }
        }
      });

      // Hide badge after animation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isLiveUpdateActive = false);
      });
    });
  }

  void _showComparison(LeagueTableEntry team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TeamComparisonSheet(team: team),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16C47F)),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: const Color(0xFF1E2433),
          child: Row(
            children: [
              SizedBox(width: 30, child: Text("#", style: _headerStyle())),
              Expanded(flex: 3, child: _headerWithLiveIndicator("الفريق")),
              Expanded(
                child: Center(child: Text("ل", style: _headerStyle())),
              ),
              Expanded(
                child: Center(child: Text("ف", style: _headerStyle())),
              ),
              Expanded(
                child: Center(child: Text("ت", style: _headerStyle())),
              ),
              Expanded(
                child: Center(child: Text("خ", style: _headerStyle())),
              ),
              Expanded(
                flex: 2,
                child: Center(child: Text("هـ", style: _headerStyle())),
              ), // Goals
              Expanded(
                child: Center(child: Text("ن", style: _headerStyle())),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            itemCount: _table.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, index) {
              final entry = _table[index];
              final isTop4 = entry.rank <= 4;
              final isRelegation = entry.rank >= 16;

              return GestureDetector(
                onLongPress: () => _showComparison(entry),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  color: Colors.transparent,
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Side Indicator
                        Container(
                          width: 4,
                          color: isTop4
                              ? const Color(0xFF16C47F)
                              : (isRelegation
                                    ? Colors.red
                                    : Colors.transparent),
                        ),

                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    "${entry.rank}",
                                    style: _cellStyle(isBold: true),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        color: Colors.grey[800],
                                        margin: const EdgeInsets.only(left: 8),
                                      ),
                                      Expanded(
                                        child: Text(
                                          entry.teamName,
                                          style: _cellStyle(isBold: true),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "${entry.played}",
                                      style: _cellStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "${entry.won}",
                                      style: _cellStyle(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "${entry.drawn}",
                                      style: _cellStyle(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "${entry.lost}",
                                      style: _cellStyle(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      "${entry.goalsFor}:${entry.goalsAgainst}",
                                      style: _cellStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Text(
                                        "${entry.points}",
                                        key: ValueKey(entry.points),
                                        style: _cellStyle(
                                          color: const Color(0xFF16C47F),
                                          isBold: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _headerWithLiveIndicator(String text) {
    return Row(
      children: [
        Text(text, style: _headerStyle()),
        if (_isLiveUpdateActive) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red, width: 0.5),
            ),
            child: const Text(
              "LIVE",
              style: TextStyle(
                color: Colors.red,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.cairo(
      color: Colors.grey,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle _cellStyle({
    Color color = Colors.white,
    bool isBold = false,
    double fontSize = 12,
  }) {
    return GoogleFonts.cairo(
      color: color,
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
  }
}
