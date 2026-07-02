import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/loop_model.dart';

class AudioPlayerService extends ChangeNotifier {
  // Lazy — never constructed on web where just_audio platform channels
  // don't exist. Accessing _player on web is always guarded by kIsWeb checks.
  AudioPlayer? _player;

  AudioPlayer get _p {
    _player ??= AudioPlayer();
    return _player!;
  }

  LoopModel? _currentLoop;
  bool _isLoading = false;
  String? _error;

  LoopModel? get currentLoop => _currentLoop;
  bool get isPlaying => kIsWeb ? false : _p.playing;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<Duration> get positionStream =>
      kIsWeb ? const Stream.empty() : _p.positionStream;
  Stream<Duration?> get durationStream =>
      kIsWeb ? const Stream.empty() : _p.durationStream;
  Stream<bool> get playingStream =>
      kIsWeb ? const Stream.empty() : _p.playingStream;

  Duration get position => kIsWeb ? Duration.zero : _p.position;
  Duration get duration => kIsWeb ? Duration.zero : (_p.duration ?? Duration.zero);

  double get progress {
    if (kIsWeb) return 0.0;
    final dur = _p.duration?.inMilliseconds ?? 0;
    if (dur == 0) return 0.0;
    return (_p.position.inMilliseconds / dur).clamp(0.0, 1.0);
  }

  double get speed => kIsWeb ? 1.0 : _p.speed;

  AudioPlayerService() {
    if (kIsWeb) return; // skip all platform-channel wiring in web preview
    _p.playingStream.listen((_) => notifyListeners());
    _p.positionStream.listen((_) => notifyListeners());
    _p.durationStream.listen((_) => notifyListeners());
    _p.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _p.seek(Duration.zero);
        _p.pause();
        notifyListeners();
      }
    });
  }

  Future<void> loadAndPlay(LoopModel loop) async {
    if (kIsWeb) return;
    _error = null;

    // If tapping the same loop that's already loaded, just toggle play/pause
    if (_currentLoop?.id == loop.id && _p.duration != null) {
      await togglePlayback();
      return;
    }

    _currentLoop = loop;
    _isLoading = true;
    notifyListeners();

    try {
      final url = loop.audioUrl;
      if (url == null || url.isEmpty) {
        _error = 'No audio available for this loop yet.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _p.stop();
      await _p.setUrl(url);
      await _p.setLoopMode(LoopMode.one);
      await _p.play();
    } catch (e) {
      _error = 'Could not load audio. Check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayback() async {
    if (kIsWeb) return;
    if (_p.playing) {
      await _p.pause();
    } else {
      await _p.play();
    }
    notifyListeners();
  }

  Future<void> seekTo(double progress) async {
    if (kIsWeb) return;
    final dur = _p.duration;
    if (dur == null) return;
    await _p.seek(Duration(milliseconds: (dur.inMilliseconds * progress).round()));
  }

  Future<void> setSpeed(double speed) async {
    if (kIsWeb) return;
    await _p.setSpeed(speed);
    notifyListeners();
  }

  Future<void> stop() async {
    if (kIsWeb) return;
    await _p.stop();
    _currentLoop = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}
