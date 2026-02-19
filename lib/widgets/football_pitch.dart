import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/player_model.dart';

class FootballPitch extends StatelessWidget {
  final List<Player> homeLineup;
  final List<Player> awayLineup;
  final String homeFormation; // e.g. "4-2-3-1"
  final String awayFormation;

  const FootballPitch({
    super.key,
    required this.homeLineup,
    required this.awayLineup,
    required this.homeFormation,
    required this.awayFormation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2E7D32), // Darker Green
                Color(0xFF388E3C), // Lighter Green
                Color(0xFF2E7D32),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            image: const DecorationImage(
              image: NetworkImage(
                "https://www.transparenttextures.com/patterns/grass.png",
              ), // Subtle texture if available, or rely on gradient
              repeat: ImageRepeat.repeat,
              opacity: 0.1,
            ),
          ),
          child: Stack(
            children: [
              // Pitch Markings
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: PitchPainter(),
              ),

              // Away Team (Top)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                height: (constraints.maxHeight / 2) - 20,
                child: _buildTeamFormation(
                  formation: awayFormation,
                  players: awayLineup,
                  isHome: false,
                ),
              ),

              // Home Team (Bottom)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                height: (constraints.maxHeight / 2) - 20,
                child: _buildTeamFormation(
                  formation: homeFormation,
                  players: homeLineup,
                  isHome: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamFormation({
    required String formation,
    required List<Player> players,
    required bool isHome,
  }) {
    // Parse formation "4-2-3-1" -> [4, 2, 3, 1]
    // Add GK -> [1, 4, 2, 3, 1] for Home (Bottom-Up)
    // For Away (Top-Down): [1, 4, 2, 3, 1]

    List<int> formationRows = formation
        .split('-')
        .map((e) => int.parse(e))
        .toList();

    // Always add Goalkeeper
    List<int> fullFormation = [1, ...formationRows]; // [1, 4, 3, 3]

    // If Home: Order is GK(Bottom) -> FW(Top).
    // Wait, visual stack is top-down.
    // Home Team (Bottom Half):
    // Row 0 (Bottom): GK (1)
    // Row 1: Def (4)
    // ...
    // So we should reverse formatting to draw from Center Line towards Goal?
    // Or simpler: Column with MainAxisAlignment.spaceEvenly.
    // For Home (Bottom half): Column should start from Top (Midfield) to Bottom (Goal).
    // So formation [1, 4, 3, 3] -> Striker is at top of this half. GK is at bottom.
    // So for Home, we want explicit order: [FW, MF, DF, GK].
    // "4-3-3" -> [1, 4, 3, 3] (GK, DF, MF, FW).
    // We want to render Top-to-Bottom: FW -> MF -> DF -> GK.
    // So we need to reverse logical formation for Home visualization.

    List<int> visualRows;
    if (isHome) {
      // Home: Bottom Half of screen.
      // Top of container is Midfield. Bottom is Goal.
      // We want FW at Top (Midfield), GK at Bottom (Goal).
      // Formation [1, 4, 3, 3] is [GK, DF, MF, FW].
      // We need reversed: [3, 3, 4, 1].
      visualRows = fullFormation.reversed.toList();
    } else {
      // Away: Top Half of screen.
      // Top of container is Goal. Bottom is Midfield.
      // We want GK at Top (Goal), FW at Bottom (Midfield).
      // Formation [1, 4, 3, 3] is [GK, DF, MF, FW].
      // We keep as is: [1, 4, 3, 3].
      visualRows = fullFormation;
    }

    int playerIndex =
        0; // We'll assume players list handles GK being first/last appropriately?
    // Actually typically players list is [GK, DF, DF, ..., FW, FW].
    // If we reverse rows for Home, we essentially need to pick players from END?
    // No, standard is usually Sorted by position or lineup order.
    // Let's assume input List<Player> is just a pool and we distribute them.
    // Ideally update standard: GK is always index 0.

    // For Home (Reversed Rows [FW, MF, DF, GK]):
    // If we iterate rows, we need to pick correct players.
    // GK is usually id 0.
    // Let's Map rows to players properly.

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: visualRows.map((count) {
        // Create a row of 'count' players
        // We need to pick the 'next' generic players for this visual row.
        // This is tricky without specific position mapping.
        // We'll just grab the next 'count' players from our list for now,
        // acknowledging this might mismatch specific named players if not sorted.
        // A robust solution would filter by role.

        // Improve Mock Logic:
        // Identify if this row is GK (count == 1 && (isFirst or isLast depending on team)).

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(count, (index) {
            // Get next player from list if available
            Player? player;
            if (playerIndex < players.length) {
              player = players[playerIndex];
              playerIndex++;
            } else {
              // Fallback if formation asks for more players than in lineup
              player = Player(
                id: 'unknown',
                name: 'Unknown',
                number: 0,
                photoUrl: '',
                position: 'UK',
              );
            }

            return _buildPlayerWidget(
              player.name,
              player.number,
              player.photoUrl,
            );
          }),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerWidget(String name, int number, String photoUrl) {
    return GestureDetector(
      onTap: () {
        // Animate or show details
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black26,
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white24,
              backgroundImage: photoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? Text(
                      number.toString(),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Center Line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Center Circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.15,
      paint,
    );

    // Penalty Areas
    // Top
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, 0),
        width: size.width * 0.5,
        height: size.height * 0.15,
      ),
      paint,
    );
    // Bottom
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height),
        width: size.width * 0.5,
        height: size.height * 0.15,
      ),
      paint,
    );

    // Corners
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: 20),
      0,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, 0), radius: 20),
      1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, size.height), radius: 20),
      -1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, size.height), radius: 20),
      3.14,
      1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
