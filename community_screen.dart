import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/section_header.dart';

// ---------------------------------------------------------------------------
// Data models (local only — no backend required)
// ---------------------------------------------------------------------------

class _CommunityPost {
  final String id;
  final String username;
  final String avatarInitials;
  final Color avatarColor;
  final String loopName;
  final String genre;
  final String mood;
  final int bpm;
  final String key;
  final int bars;
  final int likes;
  final int plays;
  final int comments;
  final List<String> tags;
  final DateTime postedAt;
  bool isLiked = false;

  _CommunityPost({
    required this.id,
    required this.username,
    required this.avatarInitials,
    required this.avatarColor,
    required this.loopName,
    required this.genre,
    required this.mood,
    required this.bpm,
    required this.key,
    required this.bars,
    required this.likes,
    required this.plays,
    required this.comments,
    required this.tags,
    required this.postedAt,
  });
}

class _RemixChallenge {
  final String title;
  final String description;
  final String genre;
  final int bpm;
  final String key;
  final int daysLeft;
  final int entries;
  final Color accentColor;

  const _RemixChallenge({
    required this.title,
    required this.description,
    required this.genre,
    required this.bpm,
    required this.key,
    required this.daysLeft,
    required this.entries,
    required this.accentColor,
  });
}

// ---------------------------------------------------------------------------
// Demo data
// ---------------------------------------------------------------------------

final _kChallenge = _RemixChallenge(
  title: 'Dark Trap Week',
  description: 'Flip this 808 groove into your hardest trap banger. '
      'Best drop takes the crown.',
  genre: 'Trap',
  bpm: 140,
  key: 'F# Minor',
  daysLeft: 3,
  entries: 87,
  accentColor: const Color(0xFFBF5AF2),
);

List<_CommunityPost> _buildDemoPosts() {
  final rng = Random(7);
  final colors = [
    const Color(0xFF00E5FF),
    const Color(0xFFBF5AF2),
    const Color(0xFF30D158),
    const Color(0xFFFFD60A),
    const Color(0xFFFF6B35),
    const Color(0xFFFF2D55),
  ];

  final data = [
    (
      'KobeBeatz',
      'KB',
      'Midnight Drill',
      'Drill',
      'Dark',
      140,
      'G Minor',
      8,
      341,
      2104,
      12,
      ['drill', 'dark', '808'],
    ),
    (
      'SynthGhost',
      'SG',
      'Vapor Dreams',
      'Synthwave',
      'Nostalgic',
      98,
      'A Major',
      4,
      218,
      1432,
      7,
      ['synthwave', 'retro', 'melodic'],
    ),
    (
      'ProdByAce',
      'PA',
      'Bounce Season',
      'Hip-Hop',
      'Energetic',
      95,
      'C Major',
      8,
      512,
      3891,
      24,
      ['hiphop', 'bounce', 'boom-bap'],
    ),
    (
      'LunaWave',
      'LW',
      'Lo-fi Sunsets',
      'Lo-fi',
      'Chill',
      76,
      'D Major',
      4,
      876,
      5230,
      41,
      ['lofi', 'chill', 'study'],
    ),
    (
      'DrumKidXL',
      'DX',
      'Afro Pulse',
      'Afrobeats',
      'Joyful',
      104,
      'E♭ Major',
      8,
      193,
      980,
      5,
      ['afrobeats', 'percussion', 'groove'],
    ),
    (
      'NightOwlMix',
      'NO',
      'Club Tech',
      'Tech House',
      'Driving',
      128,
      'F Minor',
      16,
      427,
      2670,
      18,
      ['techhouse', 'club', 'minimal'],
    ),
    (
      'MellowKing',
      'MK',
      'Rain Code',
      'R&B',
      'Romantic',
      82,
      'B♭ Minor',
      8,
      634,
      4120,
      33,
      ['rnb', 'melodic', 'rainy'],
    ),
  ];

  return List.generate(data.length, (i) {
    final d = data[i];
    return _CommunityPost(
      id: 'post_$i',
      username: d.$1,
      avatarInitials: d.$2,
      avatarColor: colors[i % colors.length],
      loopName: d.$3,
      genre: d.$4,
      mood: d.$5,
      bpm: d.$6,
      key: d.$7,
      bars: d.$8,
      likes: d.$9 + rng.nextInt(20),
      plays: d.$10 + rng.nextInt(50),
      comments: d.$11 + rng.nextInt(5),
      tags: d.$12,
      postedAt: DateTime.now().subtract(Duration(hours: i * 3 + rng.nextInt(5))),
    );
  });
}

const _kTrendingTags = [
  'All',
  'drill',
  'lofi',
  'hiphop',
  'synthwave',
  'afrobeats',
  'techhouse',
  'rnb',
  'boom-bap',
  'melodic',
  'dark',
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late List<_CommunityPost> _posts;
  String _activeTag = 'All';
  final Set<String> _playingIds = {};

  @override
  void initState() {
    super.initState();
    _posts = _buildDemoPosts();
  }

  List<_CommunityPost> get _filtered {
    if (_activeTag == 'All') return _posts;
    return _posts.where((p) => p.tags.contains(_activeTag)).toList();
  }

  void _toggleLike(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      final post = _posts.firstWhere((p) => p.id == id);
      post.isLiked = !post.isLiked;
    });
  }

  void _togglePlay(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_playingIds.contains(id)) {
        _playingIds.remove(id);
      } else {
        _playingIds
          ..clear()
          ..add(id);
      }
    });
    // Wire to AudioPlayerService when community loops have real URLs
  }

  void _showShareSheet(BuildContext ctx, _CommunityPost post) {
    final colors = Theme.of(ctx).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(ctx).textTheme;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: colors.glassBorder),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.glassBorder,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text('Share Loop', style: textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingLg),
            _ShareOption(
              icon: Icons.link,
              label: 'Copy Link',
              color: colors.neonAccent,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _ShareOption(
              icon: Icons.merge_type_rounded,
              label: 'Remix This Loop',
              color: colors.neonSecondary,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '"${post.loopName}" loaded as remix base in Generator'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _ShareOption(
              icon: Icons.download_rounded,
              label: 'Download WAV',
              color: colors.neonTertiary,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Download available on paid plan')),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingXl),
          ],
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext ctx) {
    final colors = Theme.of(ctx).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(ctx).textTheme;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: colors.glassBorder),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.glassBorder,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusRound),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text('Share Your Loop', style: textTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Post a loop from your library to the community feed.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              GlassCard(
                glowColor: colors.neonAccent,
                child: Row(
                  children: [
                    Icon(Icons.library_music_rounded,
                        color: colors.neonAccent, size: AppTheme.iconLg),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pick from Library',
                              style: textTheme.titleSmall),
                          Text('Choose a loop you generated or imported',
                              style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: colors.subtleText, size: AppTheme.iconMd),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Go to Library → select a loop → tap Share')),
                    );
                  },
                  child: const Text('Share to Community'),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadSheet(context),
        backgroundColor: colors.neonSecondary,
        foregroundColor: colorScheme.onSurface,
        icon: const Icon(Icons.add),
        label: Text(
          'Share Loop',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: AppTheme.spacingMd,
                bottom: AppTheme.spacingMd,
              ),
              title: Text(
                'Community',
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // Weekly challenge banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                0,
              ),
              child: _ChallengeBanner(challenge: _kChallenge),
            ),
          ),

          // Trending tags
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingLg,
                AppTheme.spacingMd,
                AppTheme.spacingSm,
              ),
              child: SectionHeader(
                title: 'Trending',
                trailing: Text(
                  '${filtered.length} loops',
                  style: textTheme.labelSmall
                      ?.copyWith(color: colors.subtleText),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppTheme.chipHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd),
                itemCount: _kTrendingTags.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppTheme.spacingSm),
                itemBuilder: (_, i) {
                  final tag = _kTrendingTags[i];
                  final selected = _activeTag == tag;
                  return GestureDetector(
                    onTap: () => setState(() => _activeTag = tag),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.neonAccent.withOpacity(0.15)
                            : colors.glassBg,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusRound),
                        border: Border.all(
                          color: selected
                              ? colors.neonAccent
                              : colors.glassBorder,
                          width: selected
                              ? AppTheme.borderSelected
                              : AppTheme.borderDefault,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tag == 'All' ? '# All' : '#$tag',
                        style: textTheme.labelMedium?.copyWith(
                          color: selected
                              ? colors.neonAccent
                              : colorScheme.onSurface,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Feed
          const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.spacingMd)),
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tag, size: AppTheme.iconLg * 2,
                        color: colors.subtleText),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text('No loops tagged #$_activeTag yet',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colors.subtleText)),
                    const SizedBox(height: AppTheme.spacingSm),
                    TextButton(
                      onPressed: () =>
                          setState(() => _activeTag = 'All'),
                      child: const Text('Show all'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final post = filtered[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingMd,
                      0,
                      AppTheme.spacingMd,
                      AppTheme.spacingMd,
                    ),
                    child: _PostCard(
                      post: post,
                      isPlaying: _playingIds.contains(post.id),
                      onPlay: () => _togglePlay(post.id),
                      onLike: () => _toggleLike(post.id),
                      onShare: () => _showShareSheet(context, post),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),

          const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.spacingXxl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly challenge banner
// ---------------------------------------------------------------------------

class _ChallengeBanner extends StatelessWidget {
  final _RemixChallenge challenge;

  const _ChallengeBanner({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        gradient: LinearGradient(
          colors: [
            challenge.accentColor.withOpacity(0.25),
            challenge.accentColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: challenge.accentColor.withOpacity(0.4),
          width: AppTheme.borderSelected,
        ),
        boxShadow: [
          BoxShadow(
            color: challenge.accentColor.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
                decoration: BoxDecoration(
                  color: challenge.accentColor.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                  border: Border.all(
                      color: challenge.accentColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: challenge.accentColor,
                        size: AppTheme.iconSm),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      'WEEKLY CHALLENGE',
                      style: textTheme.labelSmall?.copyWith(
                        color: challenge.accentColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs),
                decoration: BoxDecoration(
                  color: colors.warning.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Text(
                  '${challenge.daysLeft}d left',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            challenge.title,
            style: textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            challenge.description,
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              _StatPill(
                  icon: Icons.piano_rounded,
                  label: challenge.key,
                  color: challenge.accentColor),
              const SizedBox(width: AppTheme.spacingSm),
              _StatPill(
                  icon: Icons.speed_rounded,
                  label: '${challenge.bpm} BPM',
                  color: challenge.accentColor),
              const SizedBox(width: AppTheme.spacingSm),
              _StatPill(
                  icon: Icons.people_rounded,
                  label: '${challenge.entries} entries',
                  color: challenge.accentColor),
              const Spacer(),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Use the Generator to create your entry!')),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: challenge.accentColor,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: challenge.accentColor.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Text(
                    'Enter',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: AppTheme.iconSm),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Post card
// ---------------------------------------------------------------------------

class _PostCard extends StatelessWidget {
  final _CommunityPost post;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const _PostCard({
    required this.post,
    required this.isPlaying,
    required this.onPlay,
    required this.onLike,
    required this.onShare,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isPlaying
              ? colors.neonAccent.withOpacity(0.4)
              : colors.glassBorder,
          width: isPlaying
              ? AppTheme.borderSelected
              : AppTheme.borderDefault,
        ),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: colors.neonAccent.withOpacity(0.1),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: post.avatarColor.withOpacity(0.2),
                radius: 20,
                child: Text(
                  post.avatarInitials,
                  style: textTheme.labelMedium?.copyWith(
                    color: post.avatarColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.username,
                        style: textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      _timeAgo(post.postedAt),
                      style: textTheme.labelSmall
                          ?.copyWith(color: colors.subtleText),
                    ),
                  ],
                ),
              ),
              Text(
                post.genre,
                style: textTheme.labelSmall?.copyWith(
                  color: post.avatarColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Loop name + play row
          Row(
            children: [
              GestureDetector(
                onTap: onPlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPlaying
                        ? colors.neonAccent
                        : colors.neonAccent.withOpacity(0.15),
                    border: Border.all(color: colors.neonAccent),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: isPlaying
                        ? Colors.black
                        : colors.neonAccent,
                    size: AppTheme.iconMd,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.loopName,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${post.mood} • ${post.bpm} BPM • ${post.key} • ${post.bars} bars',
                      style: textTheme.labelSmall
                          ?.copyWith(color: colors.subtleText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Mini waveform
          const SizedBox(height: AppTheme.spacingMd),
          _MiniWaveform(seed: post.id.hashCode, isPlaying: isPlaying),

          // Tags
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingXs,
            runSpacing: AppTheme.spacingXs,
            children: post.tags
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.glassBg,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusRound),
                      border: Border.all(color: colors.glassBorder),
                    ),
                    child: Text(
                      '#$t',
                      style: textTheme.labelSmall
                          ?.copyWith(color: colors.subtleText),
                    ),
                  ),
                )
                .toList(),
          ),

          // Action row
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              _ActionButton(
                icon: post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '${post.likes + (post.isLiked ? 1 : 0)}',
                color: post.isLiked
                    ? const Color(0xFFFF2D55)
                    : colors.subtleText,
                onTap: onLike,
              ),
              const SizedBox(width: AppTheme.spacingLg),
              _ActionButton(
                icon: Icons.play_circle_outline_rounded,
                label: _formatCount(post.plays),
                color: colors.subtleText,
                onTap: null,
              ),
              const SizedBox(width: AppTheme.spacingLg),
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post.comments}',
                color: colors.subtleText,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comments coming soon')),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onShare,
                child: Icon(Icons.share_rounded,
                    color: colors.subtleText, size: AppTheme.iconMd),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppTheme.iconSm),
          const SizedBox(width: AppTheme.spacingXs),
          Text(label,
              style: textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: color, size: AppTheme.iconMd),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(label, style: textTheme.titleSmall),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: colors.subtleText, size: AppTheme.iconMd),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini waveform visualiser
// ---------------------------------------------------------------------------

class _MiniWaveform extends StatelessWidget {
  final int seed;
  final bool isPlaying;

  const _MiniWaveform({required this.seed, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    return RepaintBoundary(
      child: SizedBox(
        height: 32,
        child: CustomPaint(
          painter: _WaveformPainter(
            seed: seed,
            isPlaying: isPlaying,
            color: isPlaying ? colors.neonAccent : colors.subtleText,
          ),
          size: const Size(double.infinity, 32),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final int seed;
  final bool isPlaying;
  final Color color;

  const _WaveformPainter({
    required this.seed,
    required this.isPlaying,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    const barCount = 40;
    final barWidth = size.width / (barCount * 2);
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final amplitude = 0.2 + rng.nextDouble() * 0.8;
      final barHeight = amplitude * centerY;
      final x = i * barWidth * 2 + barWidth;
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.seed != seed || old.isPlaying != isPlaying || old.color != color;
}
