import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/browser_provider.dart';
import '../theme/theme.dart';
import '../widgets/browser/browser_filter_bar.dart';
import '../widgets/browser/catalog_upload_sheet.dart';
import '../widgets/browser/empty_library.dart';
import '../widgets/browser/loop_list_tile.dart';
import '../widgets/browser/loop_player_sheet.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<BrowserProvider>(
      builder: (context, provider, _) {
        final loops = provider.filteredLoops;
        final hasFilters = provider.hasActiveFilters;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openUploadSheet(context, provider),
            backgroundColor: colors.neonTertiary,
            foregroundColor: const Color(0xFF0A0A0F),
            icon: provider.isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0A0A0F),
                    ),
                  )
                : const Icon(Icons.add),
            label: Text(
              provider.isUploading ? 'Importing…' : 'Import Sample',
              style: textTheme.labelLarge?.copyWith(
                color: const Color(0xFF0A0A0F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 100,
                    backgroundColor: colorScheme.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(
                        left: AppTheme.spacingMd,
                        bottom: AppTheme.spacingMd,
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Loop Library',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          if (loops.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingSm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.neonAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                              ),
                              child: Text(
                                '${loops.length}',
                                style: textTheme.labelSmall?.copyWith(color: colors.neonAccent),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: provider.updateSearch,
                        decoration: InputDecoration(
                          hintText: 'Search loops, genres, moods…',
                          prefixIcon: Icon(Icons.search, color: colors.subtleText, size: AppTheme.iconMd),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    provider.updateSearch('');
                                  },
                                  child: Icon(Icons.close, color: colors.subtleText, size: AppTheme.iconSm),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                      child: BrowserFilterBar(provider: provider),
                    ),
                  ),
                  if (loops.isEmpty)
                    SliverFillRemaining(
                      child: EmptyLibrary(
                        hasFilters: hasFilters,
                        onClearFilters: provider.clearFilters,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final loop = loops[index];
                          return LoopListTile(
                            loop: loop,
                            onTap: () {
                              provider.openPlayer(loop);
                              _openPlayer(context, provider);
                            },
                            onFavorite: () => provider.toggleFavorite(loop.id),
                            onDelete: () => _confirmDelete(context, provider, loop.id, loop.name),
                          );
                        },
                        childCount: loops.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingXxl)),
                ],
              ),
              if (provider.isPlayerOpen)
                _MiniPlayer(provider: provider),
            ],
          ),
        );
      },
    );
  }

  void _openPlayer(BuildContext context, BrowserProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<BrowserProvider>(
          builder: (_, prov, __) => LoopPlayerSheet(provider: prov),
        ),
      ),
    ).then((_) => provider.closePlayer());
  }

  void _openUploadSheet(BuildContext context, BrowserProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const CatalogUploadSheet(),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    BrowserProvider provider,
    String id,
    String name,
  ) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(color: colors.glassBorder),
        ),
        title: const Text('Remove Sample'),
        content: Text(
          'Remove "$name" from your library?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.removeLoop(id);
            },
            child: Text(
              'Remove',
              style: TextStyle(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  final BrowserProvider provider;

  const _MiniPlayer({required this.provider});

  @override
  Widget build(BuildContext context) {
    final loop = provider.selectedLoop;
    if (loop == null) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Positioned(
      left: AppTheme.spacingMd,
      right: AppTheme.spacingMd,
      bottom: AppTheme.spacingMd,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: Consumer<BrowserProvider>(
                builder: (_, prov, __) => LoopPlayerSheet(provider: prov),
              ),
            ),
          ).then((_) async => provider.closePlayer());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: colors.neonAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: colors.neonAccent.withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: provider.togglePlayback,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.neonAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    provider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF0A0A0F),
                    size: AppTheme.iconMd,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loop.name,
                      style: textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${loop.genre} • ${loop.bpm} BPM',
                      style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => provider.closePlayer(),
                child: Icon(Icons.close, color: colors.subtleText, size: AppTheme.iconMd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
