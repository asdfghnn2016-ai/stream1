import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/match_model.dart';
import '../models/streaming_server_model.dart';
import '../services/player_service.dart';
import '../services/supabase_service.dart';
import '../widgets/player/live_player_overlay.dart';
import '../widgets/player/server_selection_sheet.dart';
import '../widgets/player/goal_animation_overlay.dart';

class LivePlayerScreen extends StatefulWidget {
  final Match match;

  const LivePlayerScreen({super.key, required this.match});

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen>
    with WidgetsBindingObserver {
  late final PlayerService _playerService;
  bool _showGoalAnimation = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    WidgetsBinding.instance.addObserver(this);

    // Defer heavy work to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScreen();
      _initializePlayer();
    });
  }

  void _setupScreen() {
    // Force Landscape & Immersive Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
  }

  Future<void> _initializePlayer() async {
    try {
      // Try fetching streams from Supabase
      List<StreamingServer> servers;
      try {
        final data = await SupabaseService.instance.getMatchStreams(
          widget.match.id,
        );
        servers = data.map((json) => StreamingServer.fromJson(json)).toList();
        if (servers.isEmpty) throw Exception('No servers');
      } catch (_) {
        // Fallback to mock servers
        servers = StreamingServer.getMockServers();
      }
      await _playerService.initialize(servers);
    } catch (e) {
      debugPrint("Player init error: $e");
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handled by Chewie/VideoPlayer automatically
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playerService.dispose();
    WakelockPlus.disable();

    // Restore Portrait & System UI
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          Center(
            child:
                _playerService.isReady &&
                    _playerService.chewieController != null
                ? Chewie(controller: _playerService.chewieController!)
                : _buildLoadingOrError(),
          ),

          // Custom Overlay (Only show when player is ready)
          if (_playerService.isReady)
            ListenableBuilder(
              listenable: _playerService,
              builder: (context, child) {
                return LivePlayerOverlay(
                  title:
                      "${widget.match.homeTeam.name} vs ${widget.match.awayTeam.name}",
                  isPlaying: _playerService.isPlaying,
                  isBuffering: _playerService.isBuffering,
                  currentServer: _playerService.currentServer,
                  onPlayPause: () => _playerService.togglePlayPause(),
                  onPip: () {}, // PiP not supported on web
                  onSettings: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("اختيار الجودة غير متوفر حالياً"),
                      ),
                    );
                  },
                  onServerSelect: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ServerSelectionSheet(
                        servers: _playerService.servers,
                        currentServer: _playerService.currentServer,
                        onServerSelected: (server) =>
                            _playerService.switchServer(server.id),
                      ),
                    );
                  },
                  onBack: () => Navigator.pop(context),
                  onGoalAnimation: () {
                    setState(() => _showGoalAnimation = true);
                  },
                );
              },
            ),

          // Goal Animation
          if (_showGoalAnimation)
            GoalAnimationOverlay(
              onAnimationComplete: () {
                setState(() => _showGoalAnimation = false);
              },
            ),

          // Back button always visible during loading
          if (_isLoading || !_playerService.isReady)
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOrError() {
    if (_playerService.errorMessage != null && !_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          const Text(
            "فشل تحميل البث",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _isLoading = true);
              _initializePlayer();
            },
            icon: const Icon(Icons.refresh),
            label: const Text("إعادة المحاولة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16C47F),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("رجوع", style: TextStyle(color: Colors.white70)),
          ),
        ],
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color(0xFF16C47F)),
        SizedBox(height: 16),
        Text(
          "جاري تحميل البث...",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
