import 'package:flutter/foundation.dart';

import '../models/loop_model.dart';
import '../services/audio_player_service.dart';
import '../services/loop_service.dart';

enum BrowserSortBy { date, bpm, key, mood, genre }

enum BrowserFilter { all, favorites, catalog }

class BrowserProvider extends ChangeNotifier {
  final LoopService _service;
  final AudioPlayerService _audio;

  BrowserProvider({required LoopService service, required AudioPlayerService audio})
      : _service = service,
        _audio = audio;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  BrowserSortBy _sortBy = BrowserSortBy.date;
  BrowserSortBy get sortBy => _sortBy;

  BrowserFilter _filter = BrowserFilter.all;
  BrowserFilter get filter => _filter;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  void addCatalogLoop(LoopModel loop) {
    _service.addCatalogLoop(loop);
    notifyListeners();
  }

  void removeLoop(String id) {
    _service.removeLoop(id);
    if (_selectedLoop?.id == id) {
      _selectedLoop = null;
      _isPlayerOpen = false;
    }
    notifyListeners();
  }

  String? _selectedGenre;
  String? get selectedGenre => _selectedGenre;

  String? _selectedMood;
  String? get selectedMood => _selectedMood;

  LoopModel? _selectedLoop;
  LoopModel? get selectedLoop => _selectedLoop;

  bool _isPlayerOpen = false;
  bool get isPlayerOpen => _isPlayerOpen;

  // Delegate playback state to the real AudioPlayerService
  bool get isPlaying => _audio.isPlaying && _audio.currentLoop?.id == _selectedLoop?.id;
  double get playbackProgress => (_audio.currentLoop?.id == _selectedLoop?.id)
      ? _audio.progress
      : 0.0;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  double _pitchShift = 0.0;
  double get pitchShift => _pitchShift;

  bool _isReversed = false;
  bool get isReversed => _isReversed;

  bool _isFadeIn = false;
  bool get isFadeIn => _isFadeIn;

  bool _isFadeOut = false;
  bool get isFadeOut => _isFadeOut;

  List<LoopModel> get filteredLoops {
    var loops = List<LoopModel>.from(_service.getAllLoops());

    if (_filter == BrowserFilter.favorites) {
      loops = loops.where((l) => l.isFavorite).toList();
    } else if (_filter == BrowserFilter.catalog) {
      loops = loops.where((l) => l.source == LoopSource.catalog).toList();
    }
    if (_selectedGenre != null) {
      loops = loops.where((l) => l.genre == _selectedGenre).toList();
    }
    if (_selectedMood != null) {
      loops = loops.where((l) => l.mood == _selectedMood).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      loops = loops.where((l) =>
          l.name.toLowerCase().contains(q) ||
          l.genre.toLowerCase().contains(q) ||
          l.mood.toLowerCase().contains(q) ||
          l.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }

    switch (_sortBy) {
      case BrowserSortBy.date:
        loops.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case BrowserSortBy.bpm:
        loops.sort((a, b) => a.bpm.compareTo(b.bpm));
      case BrowserSortBy.key:
        loops.sort((a, b) => a.key.compareTo(b.key));
      case BrowserSortBy.mood:
        loops.sort((a, b) => a.mood.compareTo(b.mood));
      case BrowserSortBy.genre:
        loops.sort((a, b) => a.genre.compareTo(b.genre));
    }

    return loops;
  }

  List<String> get availableGenres {
    final genres = _service.getAllLoops().map((l) => l.genre).toSet().toList();
    genres.sort();
    return genres;
  }

  List<String> get availableMoods {
    final moods = _service.getAllLoops().map((l) => l.mood).toSet().toList();
    moods.sort();
    return moods;
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSortBy(BrowserSortBy sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void updateFilter(BrowserFilter f) {
    _filter = f;
    notifyListeners();
  }

  void selectGenre(String? genre) {
    _selectedGenre = (_selectedGenre == genre) ? null : genre;
    notifyListeners();
  }

  void selectMood(String? mood) {
    _selectedMood = (_selectedMood == mood) ? null : mood;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedGenre = null;
    _selectedMood = null;
    _filter = BrowserFilter.all;
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _selectedGenre != null ||
      _selectedMood != null ||
      _filter != BrowserFilter.all ||
      _searchQuery.isNotEmpty;

  void openPlayer(LoopModel loop) {
    _selectedLoop = loop;
    _isPlayerOpen = true;
    _playbackSpeed = 1.0;
    _pitchShift = 0.0;
    _isReversed = false;
    _isFadeIn = false;
    _isFadeOut = false;
    notifyListeners();
    // Auto-start real audio playback
    _audio.loadAndPlay(loop);
  }

  Future<void> closePlayer() async {
    _isPlayerOpen = false;
    notifyListeners();
    await _audio.stop();
  }

  /// Delegates to AudioPlayerService — real play/pause.
  void togglePlayback() {
    _audio.togglePlayback();
    notifyListeners();
  }

  void updateProgress(double v) {
    _audio.seekTo(v);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _audio.setSpeed(speed);
    notifyListeners();
  }

  void adjustPitch(double delta) {
    _pitchShift = (_pitchShift + delta).clamp(-12.0, 12.0);
    notifyListeners();
  }

  void resetPitch() {
    _pitchShift = 0.0;
    notifyListeners();
  }

  void toggleReverse() {
    _isReversed = !_isReversed;
    notifyListeners();
  }

  void toggleFadeIn() {
    _isFadeIn = !_isFadeIn;
    notifyListeners();
  }

  void toggleFadeOut() {
    _isFadeOut = !_isFadeOut;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    _service.toggleFavorite(id);
    if (_selectedLoop?.id == id) {
      _selectedLoop = _selectedLoop!.copyWith(isFavorite: !_selectedLoop!.isFavorite);
    }
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
