import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/loop_model.dart';
import '../../providers/browser_provider.dart';
import '../../theme/theme.dart';

const _uuid = Uuid();

const _genres = [
  'Trap', 'Boom Bap', 'Memphis', 'Drill', 'Griselda', 'West Coast',
  'Lo-Fi', 'UK Garage', 'House', 'Techno', 'DnB', 'Synthwave',
  'Phonk', 'Country', 'Jazz', 'Soul', 'Gospel', 'Orchestral',
  'Hyperpop', 'Metal', 'Ambient', 'Other',
];

const _moods = [
  'Dark', 'Energetic', 'Chill', 'Aggressive', 'Emotional', 'Jazzy',
  'Psychedelic', 'Cinematic', 'Tense', 'Bouncy', 'Nostalgic', 'Uplifting',
];

const _keys = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

class CatalogUploadSheet extends StatefulWidget {
  const CatalogUploadSheet({super.key});

  @override
  State<CatalogUploadSheet> createState() => _CatalogUploadSheetState();
}

class _CatalogUploadSheetState extends State<CatalogUploadSheet> {
  // Step 0 = pick file, Step 1 = tag it, Step 2 = done
  int _step = 0;

  PlatformFile? _pickedFile;
  final _nameController = TextEditingController();
  String _genre = 'Trap';
  String _mood = 'Dark';
  String _key = 'C';
  int _bpm = 140;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aiff', 'flac', 'ogg', 'm4a'],
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    _nameController.text = p.basenameWithoutExtension(file.name);
    setState(() {
      _pickedFile = file;
      _step = 1;
    });
  }

  Future<void> _import() async {
    if (_pickedFile == null) return;
    final provider = context.read<BrowserProvider>();
    provider.setUploading(true);

    // Simulate a brief processing delay (replace with real Firebase Storage
    // upload when backend is connected: FirebaseStorage.instance.ref()...)
    await Future.delayed(const Duration(milliseconds: 800));

    final loop = LoopModel(
      id: _uuid.v4(),
      name: _nameController.text.trim().isEmpty
          ? _pickedFile!.name
          : _nameController.text.trim(),
      genre: _genre,
      mood: _mood,
      bpm: _bpm,
      key: _key,
      scale: 'Minor',
      bars: 8,
      instrument: 'Sample',
      createdAt: DateTime.now(),
      source: LoopSource.catalog,
      filePath: _pickedFile!.path,
      tags: [_genre.toLowerCase(), _mood.toLowerCase(), 'catalog'],
    );

    provider.addCatalogLoop(loop);
    provider.setUploading(false);

    if (!mounted) return;
    setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppTheme.spacingLg,
        right: AppTheme.spacingLg,
        top: AppTheme.spacingMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingXl,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == 0
            ? _PickStep(
                key: const ValueKey(0),
                colors: colors,
                textTheme: textTheme,
                onPick: _pickFile,
              )
            : _step == 1
                ? _TagStep(
                    key: const ValueKey(1),
                    colors: colors,
                    textTheme: textTheme,
                    file: _pickedFile!,
                    nameController: _nameController,
                    genre: _genre,
                    mood: _mood,
                    bpmKey: _key,
                    bpm: _bpm,
                    onGenreChanged: (v) => setState(() => _genre = v),
                    onMoodChanged: (v) => setState(() => _mood = v),
                    onKeyChanged: (v) => setState(() => _key = v),
                    onBpmChanged: (v) => setState(() => _bpm = v),
                    onBack: () => setState(() => _step = 0),
                    onImport: _import,
                  )
                : _DoneStep(
                    key: const ValueKey(2),
                    colors: colors,
                    textTheme: textTheme,
                    name: _nameController.text.trim().isEmpty
                        ? _pickedFile!.name
                        : _nameController.text.trim(),
                    onDone: () => Navigator.pop(context),
                    onImportAnother: () => setState(() {
                      _step = 0;
                      _pickedFile = null;
                      _nameController.clear();
                    }),
                  ),
      ),
    );
  }
}

// ─── Step 0: Pick File ────────────────────────────────────────────────────────

class _PickStep extends StatelessWidget {
  final AppColorsExtension colors;
  final TextTheme textTheme;
  final VoidCallback onPick;

  const _PickStep({
    super.key,
    required this.colors,
    required this.textTheme,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.glassBorder,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text('Import Sample', style: textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'Add loops, beats, and samples from your device to your personal catalog.',
          style: textTheme.bodySmall?.copyWith(color: colors.subtleText),
        ),
        const SizedBox(height: AppTheme.spacingXl),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            decoration: BoxDecoration(
              color: colors.neonTertiary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: colors.neonTertiary.withOpacity(0.4),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.neonTertiary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.audio_file_outlined,
                    color: colors.neonTertiary,
                    size: AppTheme.iconLg,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  'Tap to browse files',
                  style: textTheme.titleSmall?.copyWith(color: colors.neonTertiary),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'MP3 · WAV · AIFF · FLAC · OGG · M4A',
                  style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        _SupportedFormatsRow(colors: colors, textTheme: textTheme),
      ],
    );
  }
}

class _SupportedFormatsRow extends StatelessWidget {
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _SupportedFormatsRow({required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🎵', 'Loops'),
      ('🥁', 'Drum kits'),
      ('🎹', 'Melodies'),
      ('🎸', 'One-shots'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((item) {
        return Column(
          children: [
            Text(item.$1, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              item.$2,
              style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Step 1: Tag It ───────────────────────────────────────────────────────────

class _TagStep extends StatelessWidget {
  final AppColorsExtension colors;
  final TextTheme textTheme;
  final PlatformFile file;
  final TextEditingController nameController;
  final String genre;
  final String mood;
  final String bpmKey;
  final int bpm;
  final ValueChanged<String> onGenreChanged;
  final ValueChanged<String> onMoodChanged;
  final ValueChanged<String> onKeyChanged;
  final ValueChanged<int> onBpmChanged;
  final VoidCallback onBack;
  final VoidCallback onImport;

  const _TagStep({
    super.key,
    required this.colors,
    required this.textTheme,
    required this.file,
    required this.nameController,
    required this.genre,
    required this.mood,
    required this.bpmKey,
    required this.bpm,
    required this.onGenreChanged,
    required this.onMoodChanged,
    required this.onKeyChanged,
    required this.onBpmChanged,
    required this.onBack,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.glassBorder,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.arrow_back_ios_new,
                  color: colors.subtleText, size: AppTheme.iconMd),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tag Your Sample', style: textTheme.titleLarge),
                  Text(
                    file.name,
                    style: textTheme.labelSmall?.copyWith(color: colors.subtleText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),

        // Name field
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Sample Name',
            prefixIcon: Icon(Icons.music_note),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // Genre row
        _LabelRow(label: 'Genre', colors: colors, textTheme: textTheme),
        const SizedBox(height: AppTheme.spacingXs),
        _HorizontalChips(
          items: _genres,
          selected: genre,
          onSelect: onGenreChanged,
          color: colors.neonAccent,
          colors: colors,
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // Mood row
        _LabelRow(label: 'Mood', colors: colors, textTheme: textTheme),
        const SizedBox(height: AppTheme.spacingXs),
        _HorizontalChips(
          items: _moods,
          selected: mood,
          onSelect: onMoodChanged,
          color: colors.neonSecondary,
          colors: colors,
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // Key + BPM row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabelRow(label: 'Key', colors: colors, textTheme: textTheme),
                  const SizedBox(height: AppTheme.spacingXs),
                  _DropdownChip(
                    items: _keys,
                    value: bpmKey,
                    onChanged: onKeyChanged,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabelRow(label: 'BPM', colors: colors, textTheme: textTheme),
                  const SizedBox(height: AppTheme.spacingXs),
                  _BpmStepper(
                    value: bpm,
                    onChanged: onBpmChanged,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXl),

        // Import button
        SizedBox(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onImport,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.neonTertiary,
              foregroundColor: const Color(0xFF0A0A0F),
            ),
            icon: const Icon(Icons.library_add),
            label: const Text('Add to My Catalog'),
          ),
        ),
      ],
    );
  }
}

class _LabelRow extends StatelessWidget {
  final String label;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _LabelRow({
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.labelMedium?.copyWith(color: colors.subtleText),
    );
  }
}

class _HorizontalChips extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color color;
  final AppColorsExtension colors;

  const _HorizontalChips({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: AppTheme.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingXs),
        itemBuilder: (_, i) {
          final item = items[i];
          final isSelected = item == selected;
          return GestureDetector(
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: AppTheme.chipHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : colors.glassBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: isSelected ? color : colors.glassBorder,
                  width: isSelected ? AppTheme.borderSelected : AppTheme.borderDefault,
                ),
              ),
              child: Center(
                child: Text(
                  item,
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected ? color : colors.subtleText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _DropdownChip({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: colors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF12121A),
          isDense: true,
          isExpanded: true,
          style: textTheme.labelMedium,
          items: items
              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _BpmStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final AppColorsExtension colors;
  final TextTheme textTheme;

  const _BpmStepper({
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.chipHeight,
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        children: [
          _StepBtn(
            icon: Icons.remove,
            onTap: () => onChanged((value - 1).clamp(40, 300)),
            colors: colors,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: textTheme.labelLarge,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add,
            onTap: () => onChanged((value + 1).clamp(40, 300)),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColorsExtension colors;

  const _StepBtn({required this.icon, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
        child: Icon(icon, color: colors.subtleText, size: AppTheme.iconSm),
      ),
    );
  }
}

// ─── Step 2: Done ─────────────────────────────────────────────────────────────

class _DoneStep extends StatelessWidget {
  final AppColorsExtension colors;
  final TextTheme textTheme;
  final String name;
  final VoidCallback onDone;
  final VoidCallback onImportAnother;

  const _DoneStep({
    super.key,
    required this.colors,
    required this.textTheme,
    required this.name,
    required this.onDone,
    required this.onImportAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppTheme.spacingLg),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.neonTertiary.withOpacity(0.12),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.neonTertiary.withOpacity(AppTheme.opacityGlow),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: colors.neonTertiary,
            size: AppTheme.iconLg,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text('Sample Added!', style: textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          '"$name" is now in My Samples.',
          style: textTheme.bodyMedium?.copyWith(color: colors.subtleText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingXl),
        SizedBox(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          child: ElevatedButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SizedBox(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: onImportAnother,
            icon: const Icon(Icons.add),
            label: const Text('Import Another'),
          ),
        ),
      ],
    );
  }
}
