class GenerationParams {
  final String prompt;
  final String genre;
  final String mood;
  final int bpm;
  final String key;
  final String scale;
  final String timeSignature;
  final int bars;
  final String instrument;
  final double complexity;
  final double swing;
  final double humanization;
  final double vintageModern;
  final double cleanDirty;
  final String? inspiration;

  const GenerationParams({
    this.prompt = '',
    this.genre = 'Trap',
    this.mood = 'Dark',
    this.bpm = 140,
    this.key = 'C',
    this.scale = 'Minor',
    this.timeSignature = '4/4',
    this.bars = 4,
    this.instrument = 'Synth',
    this.complexity = 0.5,
    this.swing = 0.0,
    this.humanization = 0.3,
    this.vintageModern = 0.5,
    this.cleanDirty = 0.3,
    this.inspiration,
  });

  GenerationParams copyWith({
    String? prompt,
    String? genre,
    String? mood,
    int? bpm,
    String? key,
    String? scale,
    String? timeSignature,
    int? bars,
    String? instrument,
    double? complexity,
    double? swing,
    double? humanization,
    double? vintageModern,
    double? cleanDirty,
    String? inspiration,
  }) =>
      GenerationParams(
        prompt: prompt ?? this.prompt,
        genre: genre ?? this.genre,
        mood: mood ?? this.mood,
        bpm: bpm ?? this.bpm,
        key: key ?? this.key,
        scale: scale ?? this.scale,
        timeSignature: timeSignature ?? this.timeSignature,
        bars: bars ?? this.bars,
        instrument: instrument ?? this.instrument,
        complexity: complexity ?? this.complexity,
        swing: swing ?? this.swing,
        humanization: humanization ?? this.humanization,
        vintageModern: vintageModern ?? this.vintageModern,
        cleanDirty: cleanDirty ?? this.cleanDirty,
        inspiration: inspiration ?? this.inspiration,
      );

  static const List<String> genres = [
    'Trap', 'Boom Bap', 'Memphis', 'Drill', 'Griselda', 'West Coast',
    'Lo-Fi', 'UK Garage', 'House', 'Techno', 'DnB', 'Synthwave',
    'Phonk', 'Country', 'Jazz', 'Soul', 'Gospel', 'Orchestral',
    'Hyperpop', 'Metal', 'Ambient',
  ];

  static const List<String> moods = [
    'Dark', 'Energetic', 'Chill', 'Aggressive', 'Melancholic', 'Euphoric',
    'Eerie', 'Haunted', 'Dreamy', 'Cinematic', 'Uplifting', 'Psychedelic',
    'Nostalgic', 'Ethereal', 'Triumphant', 'Tense',
  ];

  static const List<String> keys = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  static const List<String> scales = ['Major', 'Minor', 'Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Aeolian', 'Harmonic Minor', 'Melodic Minor', 'Pentatonic', 'Blues'];

  static const List<String> timeSignatures = ['4/4', '3/4', '6/8', '5/4', '7/8'];

  static const List<int> barOptions = [1, 2, 4, 8, 16];

  static const List<String> instruments = [
    'Synth', 'Piano', 'Rhodes', 'Guitar', 'Bass', 'Strings', 'Choir',
    'Bells', 'Organ', 'Pad', 'Pluck', 'Brass', 'Flute', 'Harp',
    'Marimba', 'Cello', 'Violin', 'Saxophone',
  ];

  static const List<String> inspirations = [
    'Griselda', 'J Dilla', 'Madlib', 'Metro Boomin', 'Three 6 Mafia',
    'Timbaland', 'Kanye West', 'Mike Dean', 'Pharrell', 'DJ Paul',
    'Alchemist', 'Pierre Bourne', 'Clams Casino', 'Flying Lotus',
  ];

  static const List<String> promptExamples = [
    'Dark Memphis choir with eerie bells',
    'MF DOOM style dusty Rhodes loop',
    'Haunted carnival melody',
    'Spacey Travis Scott ambient synth',
    '90s Three 6 Mafia horror piano',
    'Vintage soul chopped sample',
    'Ethereal drill pad with reverb',
    'Lo-fi jazz piano with vinyl crackle',
  ];
}
