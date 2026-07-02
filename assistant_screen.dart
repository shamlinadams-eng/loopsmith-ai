import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';
import '../widgets/common/glass_card.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _MessageRole { user, assistant }

enum _SuggestionCategory {
  chords,
  bassline,
  drums,
  arrangement,
  mixing,
  melody,
}

class _ChatMessage {
  final _MessageRole role;
  final String text;
  final _MusicCard? card;
  final DateTime timestamp;

  _ChatMessage({
    required this.role,
    required this.text,
    this.card,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _MusicCard {
  final String title;
  final _SuggestionCategory category;
  final List<String> items;
  final String? notation;
  final Color accentColor;

  const _MusicCard({
    required this.title,
    required this.category,
    required this.items,
    this.notation,
    required this.accentColor,
  });
}

// ---------------------------------------------------------------------------
// Quick-prompt suggestions shown before any conversation
// ---------------------------------------------------------------------------

class _QuickPrompt {
  final String label;
  final IconData icon;
  final String message;
  final _SuggestionCategory category;

  const _QuickPrompt({
    required this.label,
    required this.icon,
    required this.message,
    required this.category,
  });
}

const _kQuickPrompts = [
  _QuickPrompt(
    label: 'Chord progression',
    icon: Icons.piano_rounded,
    message: 'Give me a chord progression for a dark trap beat in F# minor',
    category: _SuggestionCategory.chords,
  ),
  _QuickPrompt(
    label: 'Bassline ideas',
    icon: Icons.graphic_eq_rounded,
    message: 'What bassline patterns work over an Afrobeats groove at 104 BPM?',
    category: _SuggestionCategory.bassline,
  ),
  _QuickPrompt(
    label: 'Drum pattern',
    icon: Icons.album_rounded,
    message: 'Design a boom-bap drum pattern at 90 BPM',
    category: _SuggestionCategory.drums,
  ),
  _QuickPrompt(
    label: 'Arrangement tips',
    icon: Icons.view_timeline_rounded,
    message: 'How should I arrange a 3-minute lo-fi track?',
    category: _SuggestionCategory.arrangement,
  ),
  _QuickPrompt(
    label: 'Mixing advice',
    icon: Icons.tune_rounded,
    message: 'How do I make my 808 sit better in the mix?',
    category: _SuggestionCategory.mixing,
  ),
  _QuickPrompt(
    label: 'Melody ideas',
    icon: Icons.music_note_rounded,
    message: 'Suggest a counter-melody for a C major chord progression',
    category: _SuggestionCategory.melody,
  ),
];

// ---------------------------------------------------------------------------
// Response engine (deterministic, no API needed)
// ---------------------------------------------------------------------------

class _ResponseEngine {
  static _ChatMessage respond(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (_matches(lower, ['chord', 'progression', 'harmony', 'minor', 'major'])) {
      return _chordResponse(userMessage);
    }
    if (_matches(lower, ['bass', 'bassline', '808', 'sub'])) {
      return _basslineResponse(userMessage);
    }
    if (_matches(lower, ['drum', 'beat', 'kick', 'snare', 'hat', 'pattern'])) {
      return _drumResponse(userMessage);
    }
    if (_matches(lower, ['arrange', 'arrangement', 'structure', 'intro', 'verse', 'chorus', 'bridge'])) {
      return _arrangementResponse();
    }
    if (_matches(lower, ['mix', 'mixing', 'eq', 'compress', 'reverb', 'master', 'mastering'])) {
      return _mixingResponse(userMessage);
    }
    if (_matches(lower, ['melody', 'melod', 'lead', 'hook', 'counter'])) {
      return _melodyResponse(userMessage);
    }

    return _genericResponse(userMessage);
  }

  static bool _matches(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  static _ChatMessage _chordResponse(String msg) {
    final lower = msg.toLowerCase();
    final isMinor = lower.contains('minor') || lower.contains('dark') ||
        lower.contains('sad') || lower.contains('trap') || lower.contains('drill');

    final String key = _extractKey(lower) ?? (isMinor ? 'F# Minor' : 'C Major');
    final List<String> progression;
    final String notation;

    if (isMinor) {
      progression = [
        'i – VI – III – VII (classic dark loop)',
        'i – iv – VII – III (tension builder)',
        'i – VII – VI – VII (cinematic feel)',
        'i – III – VII – VI (emotional resolve)',
      ];
      notation = 'In $key: F#m – D – A – C#';
    } else {
      progression = [
        'I – V – vi – IV (pop foundation)',
        'I – IV – V – I (timeless resolution)',
        'ii – V – I – vi (jazz-influenced)',
        'I – iii – IV – V (ascending energy)',
      ];
      notation = 'In $key: C – G – Am – F';
    }

    return _ChatMessage(
      role: _MessageRole.assistant,
      text: 'Here are four chord progressions that will work great for your vibe. '
          'Each one has a different emotional character — try looping each for 8 bars '
          'before deciding.',
      card: _MusicCard(
        title: 'Chord Progressions — $key',
        category: _SuggestionCategory.chords,
        items: progression,
        notation: notation,
        accentColor: const Color(0xFF00E5FF),
      ),
    );
  }

  static _ChatMessage _basslineResponse(String msg) {
    final lower = msg.toLowerCase();
    final isAfro = lower.contains('afro');
    final isTrap = lower.contains('trap') || lower.contains('808');

    final List<String> patterns;
    if (isTrap) {
      patterns = [
        'Slide 808 on root note, hold for 2 beats, pitch-bend up a minor 3rd',
        'Short staccato 808 on the "and" of beat 2, let it ring to beat 4',
        'Pattern: root → root+1 semitone → root → minor 7th (gives that rolling feel)',
        'Ghost notes on 16ths between main hits — automate volume for groove',
        'Use portamento (glide) between notes: set glide to 80–120ms for smooth slides',
      ];
    } else if (isAfro) {
      patterns = [
        'Syncopated pattern: play on beats 1, the "e" of 2, and beat 4',
        'Call-and-response: bass answers the lead melody with a 2-bar phrase',
        'Emphasise the 6th degree for that bright Afrobeats lift',
        'Add a percussive ghost note (muted) on the upbeats between hits',
        'Oscillate between the root and the 5th every 2 beats for movement',
      ];
    } else {
      patterns = [
        'Root on beat 1, 5th on beat 3 — simple but powerful',
        'Walking bass: step chromatically into chord tones across 4 beats',
        'Boogie pattern: root–8va–5–6–5 on 8th notes for maximum groove',
        'Pedal point: hold root while upper voices move for tension',
        'Pentatonic run: use the minor pentatonic to connect chord roots',
      ];
    }

    return _ChatMessage(
      role: _MessageRole.assistant,
      text: 'Great question. Basslines are all about rhythm and space. '
          'Here are five patterns — focus on the first two until they feel natural, '
          'then layer complexity.',
      card: _MusicCard(
        title: 'Bassline Patterns',
        category: _SuggestionCategory.bassline,
        items: patterns,
        notation: 'Tip: Leave silence. A bass note that breathes hits harder than constant movement.',
        accentColor: const Color(0xFF30D158),
      ),
    );
  }

  static _ChatMessage _drumResponse(String msg) {
    final lower = msg.toLowerCase();
    final isBoomBap = lower.contains('boom') || lower.contains('bap') ||
        lower.contains('hip') || lower.contains('90');
    final isTrap = lower.contains('trap') || lower.contains('drill') ||
        lower.contains('140') || lower.contains('150');

    final String style;
    final List<String> items;

    if (isTrap) {
      style = 'Trap / Drill';
      items = [
        'Kick: beats 1 and 3, with a triplet roll on beat 4',
        'Snare: beat 2 and 4, clap layered for snap',
        'Hi-hats: 16th note rolls (32nd subdivisions on roll sections)',
        'Open hat: every 2 bars on the "and" of beat 4 for space',
        '808: tied to kick, let it ring — tune to the root note of the chord',
        'Perc layer: add a shaker or rim on the "e" of beat 3 for groove',
      ];
    } else if (isBoomBap) {
      style = 'Boom-Bap';
      items = [
        'Kick: beats 1 and the "and" of 2 — gives that loping, swung feel',
        'Snare: beat 2 and 4 (slightly behind the grid for vintage feel)',
        'Hi-hat: 8th notes with velocity variation (alternate 80% / 60% velocity)',
        'Open hat: on the "and" of beat 2 for that classic SP-1200 feel',
        'Vinyl crackle or room noise layer underneath everything',
        'Swing: set quantise swing to 52–58% for authentic feel',
      ];
    } else {
      style = 'Groove';
      items = [
        'Four-on-the-floor kick pattern with a ghost on beat 3-and',
        'Snare on 2 and 4, with ghost notes on 16ths for texture',
        'Hi-hat alternates open and closed on 8th notes',
        'Ride or cymbal swell going into the 2-bar transition',
        'Clap layer on the snare adds presence without volume',
        'Bass drum and bass guitar on the same notes for punch',
      ];
    }

    return _ChatMessage(
      role: _MessageRole.assistant,
      text: 'Here\'s a complete $style drum recipe. Build it piece by piece — '
          'kick first, then snare, then hats. Each element has a specific job.',
      card: _MusicCard(
        title: '$style Drum Pattern',
        category: _SuggestionCategory.drums,
        items: items,
        notation: 'Pro tip: Humanise velocity. Nothing should sit exactly on 100% — '
            'variation is what makes it groove.',
        accentColor: const Color(0xFFBF5AF2),
      ),
    );
  }

  static _ChatMessage _arrangementResponse() {
    return _ChatMessage(
      role: _MessageRole.assistant,
      text: 'A solid arrangement gives your track energy and keeps listeners engaged. '
          'Here\'s a proven structure for a 3-minute release.',
      card: _MusicCard(
        title: 'Track Arrangement Blueprint',
        category: _SuggestionCategory.arrangement,
        items: [
          '0:00–0:16  Intro — stripped back, just melody or atmosphere',
          '0:16–0:48  Verse 1 — add drums and bass, leave room',
          '0:48–1:04  Pre-chorus — build tension, remove low end',
          '1:04–1:32  Chorus — full energy, add percussion & leads',
          '1:32–2:00  Verse 2 — same as verse 1 but add a new element',
          '2:00–2:16  Bridge — unexpected key change or breakdown',
          '2:16–2:48  Final chorus — everything in, max energy',
          '2:48–3:00  Outro — remove layers one by one to close',
        ],
        notation: 'Automation tip: Use filter sweeps and volume rides between '
            'sections to make transitions feel natural.',
        accentColor: const Color(0xFFFFD60A),
      ),
    );
  }

  static _ChatMessage _mixingResponse(String msg) {
    final lower = msg.toLowerCase();
    final is808 = lower.contains('808') || lower.contains('sub') || lower.contains('bass');

    final List<String> tips;
    if (is808) {
      tips = [
        'Tune your 808 to the root note of the chord — every time, no exceptions',
        'Side-chain compress the 808 to the kick so they don\'t clash on low end',
        'High-pass everything above 250Hz on the 808 and use a separate sub layer',
        'Add subtle distortion (5–10% saturation) to make 808 audible on small speakers',
        'Use a low shelf EQ boost around 60Hz and a cut around 200–300Hz (mud)',
        'Keep 808 velocity consistent or automate it — volume inconsistency ruins the vibe',
      ];
    } else {
      tips = [
        'High-pass all instruments except kick and bass — cut below 80Hz',
        'Carve space with mid-frequency EQ cuts (200–2kHz is the crowded zone)',
        'Parallel compression: blend a heavily compressed copy with the dry signal',
        'Use short reverb (under 1.2s) on snares — long reverb muddles the mix',
        'Pan elements to create width: hi-hats at ±30%, pads at ±60%',
        'Reference your mix on phone speakers, earbuds, and car speakers',
        'Leave 3–6dB of headroom on the master bus for the mastering stage',
      ];
    }

    return _ChatMessage(
      role: _MessageRole.assistant,
      text: is808
          ? 'The 808 is one of the most technically demanding elements to mix. '
              'These steps will make it knock on every system.'
          : 'Good mixing is about subtraction, not addition. '
              'Here are the fundamentals that will clean up your sound immediately.',
      card: _MusicCard(
        title: is808 ? '808 Mixing Guide' : 'Mix Essentials',
        category: _SuggestionCategory.mixing,
        items: tips,
        notation: is808
            ? 'Always check: does your 808 still sound good in mono? If not, it\'ll '
                'disappear on club systems.'
            : 'Golden rule: if you boost a frequency, always ask if a cut somewhere '
                'else solves the same problem.',
        accentColor: const Color(0xFFFF6B35),
      ),
    );
  }

  static _ChatMessage _melodyResponse(String msg) {
    final lower = msg.toLowerCase();
    final isCounter = lower.contains('counter');

    final List<String> ideas;
    if (isCounter) {
      ideas = [
        'Move opposite to the main melody: when it goes up, go down',
        'Use longer note values to contrast with a fast main melody',
        'Stay in the same key but emphasise different scale degrees',
        'Enter in the spaces where the main melody rests',
        'Use the 3rd or 6th of each chord for consonant harmony',
        'Try answering every 2-bar phrase with a 2-bar response',
      ];
    } else {
      ideas = [
        'Start on the 3rd or 5th of the chord — root note is often too obvious',
        'Repetition first, variation second: establish a motif then twist it',
        'Use the minor pentatonic scale for instant emotional pull',
        'Leave space: a melody with rests breathes and pulls the listener in',
        'Rising lines create tension, falling lines create resolution — use both',
        'Borrow a note from outside the scale once per phrase for colour',
        'Make your melody singable — if you can\'t hum it, simplify it',
      ];
    }

    return _ChatMessage(
      role: _MessageRole.assistant,
      text: isCounter
          ? 'A good counter-melody creates conversation with the main melody. '
              'Think of it as a second vocalist answering the first.'
          : 'Here\'s how to write melodies that stick. The key is less is more — '
              'great hooks are usually 4–6 notes.',
      card: _MusicCard(
        title: isCounter ? 'Counter-Melody Techniques' : 'Melody Writing Guide',
        category: _SuggestionCategory.melody,
        items: ideas,
        notation: isCounter
            ? 'Classic example: the counter-melody in "Hotel California" — '
                'different rhythm, same emotional world.'
            : 'Exercise: write a 4-note motif. Then reverse it. Then invert it. '
                'You now have 4 variations from one idea.',
        accentColor: const Color(0xFF00E5FF),
      ),
    );
  }

  static _ChatMessage _genericResponse(String msg) {
    final rng = Random(msg.length);
    final tips = [
      'Use repetition strategically — humans love patterns with small surprises.',
      'Record every idea, even bad ones. The best ideas often come from accidents.',
      'Study one song in your genre deeply: reverse-engineer every element.',
      'Take breaks. Ear fatigue is real — 90 minutes of mixing then 20 minutes off.',
      'Less is more: the most memorable productions are often the simplest.',
      'Learn music theory incrementally — even one concept per week adds up fast.',
    ];

    return _ChatMessage(
      role: _MessageRole.assistant,
      text: tips[rng.nextInt(tips.length)],
      card: _MusicCard(
        title: 'Quick Tips',
        category: _SuggestionCategory.mixing,
        items: [
          'Try the quick-start prompts below to get specific advice',
          'Ask me about chords, basslines, drums, arrangement, or mixing',
          'Be specific — "808 in F# minor trap beat at 140 BPM" gets better answers',
        ],
        accentColor: const Color(0xFF00E5FF),
      ),
    );
  }

  static String? _extractKey(String text) {
    const keys = [
      'c major', 'c minor', 'd major', 'd minor',
      'e major', 'e minor', 'f major', 'f minor',
      'g major', 'g minor', 'a major', 'a minor',
      'b major', 'b minor', 'f# minor', 'f# major',
      'bb minor', 'eb major',
    ];
    for (final k in keys) {
      if (text.contains(k)) {
        return k.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isThinking = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    final userMsg = text.trim();
    _inputController.clear();

    setState(() {
      _messages.add(_ChatMessage(role: _MessageRole.user, text: userMsg));
      _isThinking = true;
    });
    _scrollToBottom();

    // Simulate AI "thinking" delay
    await Future.delayed(
        Duration(milliseconds: 600 + Random().nextInt(800)));

    if (!mounted) return;
    final response = _ResponseEngine.respond(userMsg);

    setState(() {
      _messages.add(response);
      _isThinking = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() => _messages.clear());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasMessages = _messages.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.neonSecondary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: colors.neonSecondary.withOpacity(0.4)),
              ),
              child: Icon(Icons.psychology_rounded,
                  color: colors.neonSecondary, size: AppTheme.iconSm),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Copilot',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('Music production assistant',
                    style: textTheme.labelSmall
                        ?.copyWith(color: colors.subtleText)),
              ],
            ),
          ],
        ),
        actions: [
          if (hasMessages)
            IconButton(
              icon: Icon(Icons.refresh_rounded,
                  color: colors.subtleText, size: AppTheme.iconMd),
              tooltip: 'Clear chat',
              onPressed: _clearChat,
            ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: hasMessages
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm),
                    itemCount: _messages.length + (_isThinking ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _messages.length) {
                        return const _ThinkingBubble();
                      }
                      final msg = _messages[i];
                      return msg.role == _MessageRole.user
                          ? _UserBubble(message: msg)
                          : _AssistantBubble(message: msg);
                    },
                  )
                : _EmptyState(
                    onQuickPrompt: (prompt) => _send(prompt.message),
                  ),
          ),

          // Input bar
          _InputBar(
            controller: _inputController,
            isThinking: _isThinking,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state with quick prompts
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final void Function(_QuickPrompt) onQuickPrompt;

  const _EmptyState({required this.onQuickPrompt});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingLg),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.neonSecondary.withOpacity(0.12),
              border: Border.all(
                  color: colors.neonSecondary.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.neonSecondary.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(Icons.psychology_rounded,
                color: colors.neonSecondary, size: 36),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text('AI Music Copilot',
              style: textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Ask me anything about music production.\nChords, drums, mixing, arrangement — I\'ve got you.',
            style: textTheme.bodyMedium
                ?.copyWith(color: colors.subtleText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Try asking…',
                style: textTheme.titleSmall
                    ?.copyWith(color: colors.subtleText)),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.spacingSm,
            mainAxisSpacing: AppTheme.spacingSm,
            childAspectRatio: 2.2,
            children: _kQuickPrompts
                .map((p) => _QuickPromptChip(
                      prompt: p,
                      onTap: () => onQuickPrompt(p),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final _QuickPrompt prompt;
  final VoidCallback onTap;

  const _QuickPromptChip({required this.prompt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: colors.glassBorder),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: Row(
          children: [
            Icon(prompt.icon,
                color: colors.neonSecondary, size: AppTheme.iconSm),
            const SizedBox(width: AppTheme.spacingXs),
            Expanded(
              child: Text(
                prompt.label,
                style: textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubbles
// ---------------------------------------------------------------------------

class _UserBubble extends StatelessWidget {
  final _ChatMessage message;

  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 60),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm + 2),
              decoration: BoxDecoration(
                color: colors.neonAccent.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  topRight: Radius.circular(AppTheme.radiusLarge),
                  bottomLeft: Radius.circular(AppTheme.radiusLarge),
                  bottomRight: Radius.circular(AppTheme.radiusSmall),
                ),
                border: Border.all(
                    color: colors.neonAccent.withOpacity(0.3)),
              ),
              child: Text(
                message.text,
                style: textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.neonAccent.withOpacity(0.2),
            child: Icon(Icons.person_rounded,
                color: colors.neonAccent, size: AppTheme.iconSm),
          ),
        ],
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final _ChatMessage message;

  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.neonSecondary.withOpacity(0.15),
              border: Border.all(
                  color: colors.neonSecondary.withOpacity(0.4)),
            ),
            child: Icon(Icons.psychology_rounded,
                color: colors.neonSecondary, size: AppTheme.iconSm),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm + 2),
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusSmall),
                      topRight: Radius.circular(AppTheme.radiusLarge),
                      bottomLeft: Radius.circular(AppTheme.radiusLarge),
                      bottomRight: Radius.circular(AppTheme.radiusLarge),
                    ),
                    border: Border.all(color: colors.glassBorder),
                  ),
                  child: Text(message.text, style: textTheme.bodyMedium),
                ),
                if (message.card != null) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  _MusicSuggestionCard(card: message.card!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }
}

class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.neonSecondary.withOpacity(0.15),
              border: Border.all(
                  color: colors.neonSecondary.withOpacity(0.4)),
            ),
            child: Icon(Icons.psychology_rounded,
                color: colors.neonSecondary, size: AppTheme.iconSm),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: colors.glassBorder),
            ),
            // Use AnimatedBuilder painting color alpha directly — Opacity widget
            // forces a compositing layer on iOS which is expensive for animation.
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) {
                    final alpha = i == 0
                        ? _anim.value
                        : i == 1
                            ? (_anim.value + 0.2).clamp(0.0, 1.0)
                            : (_anim.value + 0.4).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          // Paint alpha directly into the color — no Opacity widget,
                          // no extra compositing layer.
                          color: colors.neonSecondary.withOpacity(alpha),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Music suggestion card
// ---------------------------------------------------------------------------

class _MusicSuggestionCard extends StatelessWidget {
  final _MusicCard card;

  const _MusicSuggestionCard({required this.card});

  IconData get _icon {
    switch (card.category) {
      case _SuggestionCategory.chords:
        return Icons.piano_rounded;
      case _SuggestionCategory.bassline:
        return Icons.graphic_eq_rounded;
      case _SuggestionCategory.drums:
        return Icons.album_rounded;
      case _SuggestionCategory.arrangement:
        return Icons.view_timeline_rounded;
      case _SuggestionCategory.mixing:
        return Icons.tune_rounded;
      case _SuggestionCategory.melody:
        return Icons.music_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      glowColor: card.accentColor,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: card.accentColor.withOpacity(0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge - 1),
                topRight: Radius.circular(AppTheme.radiusLarge - 1),
              ),
              border: Border(
                bottom: BorderSide(color: card.accentColor.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(_icon, color: card.accentColor, size: AppTheme.iconSm),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    card.title,
                    style: textTheme.labelLarge?.copyWith(
                      color: card.accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final all = card.items.join('\n') +
                        (card.notation != null
                            ? '\n\n${card.notation}'
                            : '');
                    Clipboard.setData(ClipboardData(text: all));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Copied to clipboard')),
                    );
                  },
                  child: Icon(Icons.copy_rounded,
                      color: colors.subtleText, size: AppTheme.iconSm),
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...card.items.asMap().entries.map(
                      (e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin:
                                  const EdgeInsets.only(right: AppTheme.spacingSm, top: 1),
                              decoration: BoxDecoration(
                                color: card.accentColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${e.key + 1}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: card.accentColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(e.value,
                                  style: textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (card.notation != null) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: card.accentColor.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(
                          color: card.accentColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      card.notation!,
                      style: textTheme.labelSmall?.copyWith(
                        color: card.accentColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input bar
// ---------------------------------------------------------------------------

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isThinking;
  final Future<void> Function(String) onSend;

  const _InputBar({
    required this.controller,
    required this.isThinking,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppTheme.spacingMd, AppTheme.spacingSm, AppTheme.spacingMd,
          AppTheme.spacingMd + bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        border: Border(
            top: BorderSide(color: colors.glassBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isThinking,
              textInputAction: TextInputAction.send,
              onSubmitted: isThinking ? null : onSend,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Ask about chords, drums, mixing…',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                  borderSide: BorderSide(color: colors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                  borderSide: BorderSide(color: colors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                  borderSide: BorderSide(
                      color: colors.neonSecondary,
                      width: AppTheme.borderSelected),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          GestureDetector(
            onTap: isThinking ? null : () => onSend(controller.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isThinking
                    ? colors.neonSecondary.withOpacity(0.3)
                    : colors.neonSecondary,
                boxShadow: isThinking
                    ? null
                    : [
                        BoxShadow(
                          color: colors.neonSecondary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: -4,
                        ),
                      ],
              ),
              child: isThinking
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: AppTheme.iconMd),
            ),
          ),
        ],
      ),
    );
  }
}
