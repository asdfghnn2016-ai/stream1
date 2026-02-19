import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GoalAnimationOverlay extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const GoalAnimationOverlay({super.key, required this.onAnimationComplete});

  @override
  State<GoalAnimationOverlay> createState() => _GoalAnimationOverlayState();
}

class _GoalAnimationOverlayState extends State<GoalAnimationOverlay> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shockwave effect
          Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF16C47F), width: 4),
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOut)
              .fadeOut(duration: 600.ms),

          // Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                    "GOAAAL!",
                    style: GoogleFonts.cairo(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        const BoxShadow(
                          color: Color(0xFF16C47F),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  )
                  .animate(onComplete: (c) => widget.onAnimationComplete())
                  .scale(duration: 400.ms, curve: Curves.elasticOut)
                  .shake(delay: 400.ms, duration: 400.ms)
                  .fadeOut(delay: 2000.ms, duration: 500.ms),

              const SizedBox(height: 10),
              Text(
                    "الهلال يسجل!",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.5, end: 0)
                  .fadeOut(delay: 2000.ms, duration: 500.ms),
            ],
          ),
        ],
      ),
    );
  }
}
