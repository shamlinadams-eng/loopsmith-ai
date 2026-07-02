import 'dart:math';

import '../models/generation_params.dart';
import '../models/loop_model.dart';
import 'replicate_service.dart';

/// Demo loops with real royalty-free audio so the player works out of the box.
const _demoLoops = [
  (
    name: 'Dark Memphis Bells',
    genre: 'Memphis',
    mood: 'Dark',
    bpm: 73,
    key: 'C',
    scale: 'Minor',
    bars: 4,
    instrument: 'Piano',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  ),
  (
    name: 'Dusty Boom Bap Rhodes',
    genre: 'Boom Bap',
    mood: 'Nostalgic',
    bpm: 90,
    key: 'F',
    scale: 'Major',
    bars: 4,
    instrument: 'Rhodes',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
  ),
  (
    name: 'Spacey Trap Synth',
    genre: 'Trap',
    mood: 'Ethereal',
    bpm: 140,
    key: 'G',
    scale: 'Minor',
    bars: 8,
    instrument: 'Synth',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
  ),
  (
    name: 'Lo-Fi Chill Chords',
    genre: 'Lo-Fi',
    mood: 'Chill',
    bpm: 85,
    key: 'A',
    scale: 'Minor',
    bars: 4,
    instrument: 'Piano',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
  ),
  (
    name: 'West Coast Funk',
    genre: 'West Coast',
    mood: 'Smooth',
    bpm: 96,
    key: 'D',
    scale: 'Major',
    bars: 8,
    instrument: 'Guitar',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
  ),
];

class LoopService {
  final ReplicateService _replicate;
  final List<LoopModel> _loops = [];
  final _random = Random();

  LoopService(this._replicate) {
    _seedDemoLoops();
  }

  void _seedDemoLoops() {
    for (final d in _demoLoops) {
      _loops.add(LoopModel(
        id: 'demo_${d.name.hashCode}',
        name: d.name,
        genre: d.genre,
        mood: d.mood,
        bpm: d.bpm,
        key: d.key,
        scale: d.scale,
        bars: d.bars,
        instrument: d.instrument,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        durationSeconds: _calculateDuration(d.bpm, d.bars),
        tags: [d.genre.toLowerCase(), d.mood.toLowerCase()],
        audioUrl: d.url,
      ));
    }
  }

  void addCatalogLoop(LoopModel loop) {
    _loops.insert(0, loop);
  }

  void removeLoop(String id) {
    _loops.removeWhere((l) => l.id == id);
  }

  List<LoopModel> getAllLoops() => List.unmodifiable(_loops);

  List<LoopModel> getRecentLoops({int limit = 5}) {
    final sorted = List<LoopModel>.from(_loops)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  Future<LoopModel> generateLoop(GenerationParams params) async {
    final promptName = params.prompt.isNotEmpty
        ? params.prompt
        : '${params.mood} ${params.genre} ${params.instrument}';

    String? audioUrl;

    if (_replicate.hasApiKey) {
      try {
        // Real AI generation via Replicate MusicGen
        audioUrl = await _replicate.generateAudio(params);
      } on ReplicateWebNotSupportedException {
        // Web preview can't call Replicate — fall back silently
        audioUrl = _demoLoops[_random.nextInt(_demoLoops.length)].url;
      }
      // Any other exception (bad key, network, 422) bubbles up to the UI
    } else {
      // No API key yet — fall back to a demo audio so something plays
      await Future.delayed(const Duration(seconds: 2));
      audioUrl = _demoLoops[_random.nextInt(_demoLoops.length)].url;
    }

    final loop = LoopModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: promptName,
      genre: params.genre,
      mood: params.mood,
      bpm: params.bpm,
      key: params.key,
      scale: params.scale,
      bars: params.bars,
      instrument: params.instrument,
      createdAt: DateTime.now(),
      durationSeconds: _calculateDuration(params.bpm, params.bars),
      tags: [params.genre.toLowerCase(), params.mood.toLowerCase()],
      audioUrl: audioUrl,
    );

    _loops.insert(0, loop);
    return loop;
  }

  double _calculateDuration(int bpm, int bars) {
    const beatsPerBar = 4.0;
    final totalBeats = beatsPerBar * bars;
    return totalBeats / bpm * 60.0;
  }

  void toggleFavorite(String id) {
    final index = _loops.indexWhere((l) => l.id == id);
    if (index != -1) {
      _loops[index] = _loops[index].copyWith(isFavorite: !_loops[index].isFavorite);
    }
  }

  int get todayGenerationCount {
    final today = DateTime.now();
    return _loops.where((l) =>
        l.createdAt.year == today.year &&
        l.createdAt.month == today.month &&
        l.createdAt.day == today.day &&
        !l.id.startsWith('demo_')).length;
  }

  int get remainingGenerations => max(0, 10 - todayGenerationCount);

  String getRandomPromptExample() {
    return GenerationParams.promptExamples[
        _random.nextInt(GenerationParams.promptExamples.length)];
  }
}
