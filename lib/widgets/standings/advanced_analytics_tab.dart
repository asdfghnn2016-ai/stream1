import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/standings_model.dart';

class AdvancedAnalyticsTab extends StatelessWidget {
  const AdvancedAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = LeagueTableEntry.getMockTable();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle("الأعلى في معدل الأهداف المتوقعة (xG)"),
        ...teams.map((t) => _buildAnalyticsRow(t, t.xG, "xG", 3.0)),

        const SizedBox(height: 24),
        _buildSectionTitle("الأعلى استحواذاً"),
        ...teams.map((t) => _buildAnalyticsRow(t, t.possession, "%", 100.0)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: const Color(0xFF16C47F),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildAnalyticsRow(
    LeagueTableEntry team,
    double value,
    String suffix,
    double max,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Value
          SizedBox(
            width: 50,
            child: Text(
              "$value$suffix",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Bar
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2433),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (value / max).clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16C47F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Team Name
          SizedBox(
            width: 80,
            child: Text(
              team.teamName,
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          // Logo
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            radius: 12,
            child: const Icon(Icons.shield, color: Colors.white70, size: 12),
          ),
        ],
      ),
    );
  }
}
