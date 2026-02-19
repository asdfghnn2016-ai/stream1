import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/standings_model.dart';

class TopScorersTab extends StatefulWidget {
  final bool isAssists;
  const TopScorersTab({super.key, this.isAssists = false});

  @override
  State<TopScorersTab> createState() => _TopScorersTabState();
}

class _TopScorersTabState extends State<TopScorersTab> {
  List<PlayerStats> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        if (widget.isAssists) {
          _players = PlayerStats.getMockContributors()
            ..sort(
              (a, b) => b.assists.compareTo(a.assists),
            ); // Use contributors as mock for assists
        } else {
          _players = PlayerStats.getMockScorers();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16C47F)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final player = _players[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2433),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 30,
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.cairo(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Avatar
              CircleAvatar(
                backgroundColor: Colors.grey[800],
                radius: 20,
                child: const Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Name & Team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: Colors.grey[800],
                        ), // Small team logo
                        const SizedBox(width: 4),
                        Text(
                          player.teamName,
                          style: GoogleFonts.cairo(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stat
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0F1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF16C47F).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  widget.isAssists ? "${player.assists}" : "${player.goals}",
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF16C47F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
