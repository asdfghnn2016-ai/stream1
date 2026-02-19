import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/streaming_server_model.dart';

class LivePlayerOverlay extends StatefulWidget {
  final String title;
  final bool isPlaying;
  final bool isBuffering;
  final StreamingServer? currentServer;
  final VoidCallback onPlayPause;
  final VoidCallback onPip; // Replaces onFullscreen
  final VoidCallback onSettings;
  final VoidCallback onServerSelect;
  final VoidCallback onBack;
  final VoidCallback onGoalAnimation;

  const LivePlayerOverlay({
    super.key,
    required this.title,
    required this.isPlaying,
    required this.isBuffering,
    required this.currentServer,
    required this.onPlayPause,
    required this.onPip,
    required this.onSettings,
    required this.onServerSelect,
    required this.onBack,
    required this.onGoalAnimation,
  });

  @override
  State<LivePlayerOverlay> createState() => _LivePlayerOverlayState();
}

class _LivePlayerOverlayState extends State<LivePlayerOverlay> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      // Reduced to 3s
      if (mounted && widget.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _onInteraction() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      onDoubleTap: widget.onGoalAnimation,
      behavior: HitTestBehavior.translucent,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Stack(
            children: [
              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Network Quality Indicator
                      const Icon(
                        Icons.signal_cellular_alt,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      // Live Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .fade(duration: 800.ms),
                            const SizedBox(width: 4),
                            Text(
                              "LIVE",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Center - Buffering
              if (widget.isBuffering)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF16C47F)),
                ),

              // Bottom Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left controls (Server/Quality)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _onInteraction();
                              widget.onServerSelect();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.dns,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.currentServer?.name ?? "Auto",
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              _onInteraction();
                              widget.onSettings();
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Center Play/Pause
                      // Moved to center for better reachability or kept at bottom?
                      // User asked for "Bottom: Play / Pause, Live status indicator, Server selector, PiP button"
                      // Let's keep play/pause in center of bottom row for now.
                      IconButton(
                        onPressed: () {
                          _onInteraction();
                          widget.onPlayPause();
                        },
                        iconSize: 48,
                        icon: Icon(
                          widget.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: const Color(0xFF16C47F),
                        ),
                      ),

                      // PiP Button (Replaces Fullscreen)
                      IconButton(
                        onPressed: () {
                          _onInteraction();
                          widget.onPip();
                        },
                        icon: const Icon(
                          Icons.picture_in_picture_alt,
                          color: Colors.white,
                          size: 28,
                        ),
                        tooltip: "Picture in Picture",
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
  }
}
