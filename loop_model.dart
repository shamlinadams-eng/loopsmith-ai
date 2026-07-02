enum LoopSource { aiGenerated, catalog }

class LoopModel {
  final String id;
  final String name;
  final String genre;
  final String mood;
  final int bpm;
  final String key;
  final String scale;
  final int bars;
  final String instrument;
  final DateTime createdAt;
  final bool isFavorite;
  final List<String> tags;
  final double durationSeconds;
  final LoopSource source;
  final String? filePath;
  final String? audioUrl;

  const LoopModel({
    required this.id,
    required this.name,
    required this.genre,
    required this.mood,
    required this.bpm,
    required this.key,
    required this.scale,
    required this.bars,
    required this.instrument,
    required this.createdAt,
    this.isFavorite = false,
    this.tags = const [],
    this.durationSeconds = 8.0,
    this.source = LoopSource.aiGenerated,
    this.filePath,
    this.audioUrl,
  });

  LoopModel copyWith({
    String? name,
    bool? isFavorite,
    List<String>? tags,
    String? filePath,
    String? audioUrl,
  }) =>
      LoopModel(
        id: id,
        name: name ?? this.name,
        genre: genre,
        mood: mood,
        bpm: bpm,
        key: key,
        scale: scale,
        bars: bars,
        instrument: instrument,
        createdAt: createdAt,
        isFavorite: isFavorite ?? this.isFavorite,
        tags: tags ?? this.tags,
        durationSeconds: durationSeconds,
        source: source,
        filePath: filePath ?? this.filePath,
        audioUrl: audioUrl ?? this.audioUrl,
      );
}
