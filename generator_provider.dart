import 'package:flutter/foundation.dart';

import '../models/generation_params.dart';
import '../models/loop_model.dart';
import '../services/audio_player_service.dart';
import '../services/loop_service.dart';

class GeneratorProvider extends ChangeNotifier {
  final LoopService _service;
  final AudioPlayerService _audio;

  GeneratorProvider({required LoopService service, required AudioPlayerService audio})
      : _service = service,
        _audio = audio;

  GenerationParams _params = const GenerationParams();
  GenerationParams get params => _params;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  LoopModel? _lastGenerated;
  LoopModel? get lastGenerated => _lastGenerated;

  bool _showAdvanced = false;
  bool get showAdvanced => _showAdvanced;

  String? _error;
  String? get error => _error;

  // Delegate playback state to the real AudioPlayerService
  bool get isPlaying => _audio.isPlaying && _audio.currentLoop?.id == _lastGenerated?.id;
  double get playbackProgress => (_audio.currentLoop?.id == _lastGenerated?.id)
      ? _audio.progress
      : 0.0;

  List<LoopModel> get recentLoops => _service.getRecentLoops();
  int get remainingGenerations => _service.remainingGenerations;

  void updatePrompt(String prompt) {
    _params = _params.copyWith(prompt: prompt);
    notifyListeners();
  }

  void updateGenre(String genre) {
    _params = _params.copyWith(genre: genre);
    notifyListeners();
  }

  void updateMood(String mood) {
    _params = _params.copyWith(mood: mood);
    notifyListeners();
  }

  void updateBpm(int bpm) {
    _params = _params.copyWith(bpm: bpm);
    notifyListeners();
  }

  void updateKey(String key) {
    _params = _params.copyWith(key: key);
    notifyListeners();
  }

  void updateScale(String scale) {
    _params = _params.copyWith(scale: scale);
    notifyListeners();
  }

  void updateBars(int bars) {
    _params = _params.copyWith(bars: bars);
    notifyListeners();
  }

  void updateInstrument(String instrument) {
    _params = _params.copyWith(instrument: instrument);
    notifyListeners();
  }

  void updateComplexity(double v) {
    _params = _params.copyWith(complexity: v);
    notifyListeners();
  }

  void updateSwing(double v) {
    _params = _params.copyWith(swing: v);
    notifyListeners();
  }

  void updateHumanization(double v) {
    _params = _params.copyWith(humanization: v);
    notifyListeners();
  }

  void updateVintageModern(double v) {
    _params = _params.copyWith(vintageModern: v);
    notifyListeners();
  }

  void updateCleanDirty(double v) {
    _params = _params.copyWith(cleanDirty: v);
    notifyListeners();
  }

  void updateInspiration(String? inspiration) {
    _params = _params.copyWith(inspiration: inspiration);
    notifyListeners();
  }

  void toggleAdvanced() {
    _showAdvanced = !_showAdvanced;
    notifyListeners();
  }

  /// Delegates to AudioPlayerService — real audio playback.
  Future<void> togglePlayback() async {
    if (_lastGenerated == null) return;
    await _audio.loadAndPlay(_lastGenerated!);
    notifyListeners();
  }

  /// No-op kept for legacy call sites; use togglePlayback() instead.
  void updatePlaybackProgress(double v) {}

  Future<void> generate() async {
    if (_isGenerating) return;
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      // Stop any currently playing audio before generating a new loop
      await _audio.stop();
      _lastGenerated = await _service.generateLoop(_params);
    } catch (e) {
      _error = 'Generation failed. Please try again.';
    }

    _isGenerating = false;
    notifyListeners();
  }

  void applySmartControl(String control) {
    switch (control) {
      case 'Make darker':
        _params = _params.copyWith(mood: 'Dark', cleanDirty: 0.7);
      case 'More aggressive':
        _params = _params.copyWith(mood: 'Aggressive', complexity: 0.8);
      case 'More emotional':
        _params = _params.copyWith(mood: 'Melancholic', humanization: 0.8);
      case 'More jazzy':
        _params = _params.copyWith(swing: 0.7, complexity: 0.7);
      case 'More cinematic':
        _params = _params.copyWith(mood: 'Cinematic', instrument: 'Strings');
      case 'Add swing':
        _params = _params.copyWith(swing: (_params.swing + 0.2).clamp(0.0, 1.0));
      case 'Simplify':
        _params = _params.copyWith(complexity: (_params.complexity - 0.3).clamp(0.0, 1.0));
      case 'Add tension':
        _params = _params.copyWith(mood: 'Tense', cleanDirty: 0.6);
      case 'Add bounce':
        _params = _params.copyWith(swing: 0.5, humanization: 0.5);
      case 'Randomize':
        _params = _params.copyWith(
          complexity: (DateTime.now().millisecond % 100) / 100.0,
          swing: (DateTime.now().second % 100) / 100.0,
        );
    }
    notifyListeners();
  }

  String get randomPromptHint => _service.getRandomPromptExample();
}
