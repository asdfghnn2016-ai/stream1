import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/standings_model.dart';

class TeamComparisonSheet extends StatelessWidget {
  final LeagueTableEntry team;

  const TeamComparisonSheet({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Team Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                team.teamName,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.grey[800],
                radius: 20,
                child: const Icon(Icons.shield, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "المركز ${team.rank} • ${team.points} نقطة",
            style: GoogleFonts.cairo(
              color: const Color(0xFF16C47F),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Stats Layout
          _buildStatRow(
            "الأهداف (له/عليه)",
            "${team.goalsFor} / ${team.goalsAgainst}",
            0.8,
          ),
          _buildStatRow(
            "معدل الأهداف المتوقعة (xG)",
            "${team.xG}",
            team.xG / 3.0,
          ),
          _buildStatRow(
            "الاستحواذ",
            "${team.possession}%",
            team.possession / 100,
          ),
          _buildStatRow(
            "دقة التمرير",
            "${team.passingAccuracy}%",
            team.passingAccuracy / 100,
          ),

          const SizedBox(height: 24),

          // Form
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "آخر 5 مباريات",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: team.form.map((f) => _buildFormBadge(f)).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF1E2433),
              color: const Color(0xFF16C47F),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBadge(String result) {
    Color color;
    if (result == "W") {
      color = const Color(0xFF16C47F);
    } else if (result == "D") {
      color = Colors.grey;
    } else {
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        result,
        style: GoogleFonts.cairo(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
