import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/streaming_server_model.dart';

class PlayerService extends ChangeNotifier {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  List<StreamingServer> _servers = [];
  int _currentServerIndex = 0;
  bool _isDisposed = false;
  String? _errorMessage;

  ChewieController? get chewieController => _chewieController;
  VideoPlayerController? get videoController => _videoController;
  StreamingServer? get currentServer =>
      _servers.isNotEmpty ? _servers[_currentServerIndex] : null;
  List<StreamingServer> get servers => _servers;
  String? get errorMessage => _errorMessage;

  /// Whether the player is currently playing
  bool get isPlaying => _videoController?.value.isPlaying ?? false;

  /// Whether the player is currently buffering
  bool get isBuffering => _videoController?.value.isBuffering ?? false;

  /// Whether the player is initialized and ready
  bool get isReady =>
      _videoController != null && _videoController!.value.isInitialized;

  // Initialize with a list of servers
  Future<void> initialize(List<StreamingServer> servers) async {
    _isDisposed = false;
    _errorMessage = null;
    _servers = servers;
    _currentServerIndex = 0;
    await _setupController();
  }

  Future<void> _setupController() async {
    if (_servers.isEmpty || _isDisposed) return;

    final server = _servers[_currentServerIndex];

    // Dispose previous controllers
    await _disposeControllers();

    try {
      // Create VideoPlayerController for the stream URL
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(server.url),
        httpHeaders: server.headers ?? {},
      );

      // Initialize the video controller
      await _videoController!.initialize();

      if (_isDisposed) return;

      // Create Chewie controller with our custom config
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: false, // We use our own overlay
        aspectRatio: 16 / 9,
        allowFullScreen: false, // We handle orientation manually
        allowMuting: true,
        isLive: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  "خطأ في البث",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      _errorMessage = null;

      // Listen for errors
      _videoController!.addListener(_onVideoStateChanged);

      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Player setup error: $e");
      _errorMessage = e.toString();
      if (!_isDisposed) {
        notifyListeners();
        // Try failover to next server
        _handleStreamError();
      }
    }
  }

  void _onVideoStateChanged() {
    if (_isDisposed) return;
    if (_videoController?.value.hasError == true) {
      _handleStreamError();
    }
    notifyListeners();
  }

  /// Switch to a different server by ID
  Future<void> switchServer(String serverId) async {
    final index = _servers.indexWhere((s) => s.id == serverId);
    if (index != -1 && index != _currentServerIndex) {
      _currentServerIndex = index;
      await _setupController();
    }
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    notifyListeners();
  }

  /// Handle stream errors with automatic failover
  void _handleStreamError() {
    debugPrint("Stream error detected. Attempting failover...");
    if (_isDisposed) return;

    if (_currentServerIndex < _servers.length - 1) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!_isDisposed) {
          _currentServerIndex++;
          _setupController();
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isDisposed) {
          _currentServerIndex = 0; // Reset to first server
          _setupController();
        }
      });
    }
  }

  Future<void> _disposeControllers() async {
    _videoController?.removeListener(_onVideoStateChanged);
    _chewieController?.dispose();
    _chewieController = null;
    await _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoController?.removeListener(_onVideoStateChanged);
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }
}
