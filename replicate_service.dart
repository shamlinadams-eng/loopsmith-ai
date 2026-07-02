import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/generation_params.dart';

const _prefKey = 'replicate_api_key';

/// Calls Replicate's hosted MusicGen model to generate a real audio loop.
/// Sign up at replicate.com — costs ~$0.004 per generation.
class ReplicateService extends ChangeNotifier {
  String? _apiKey;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;
  String? get maskedKey =>
      hasApiKey ? '${_apiKey!.substring(0, 6)}••••••••••••${_apiKey!.substring(_apiKey!.length - 4)}' : null;

  ReplicateService() {
    _loadKey();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_prefKey);
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, key.trim());
    _apiKey = key.trim();
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _apiKey = null;
    notifyListeners();
  }

  // MusicGen stereo-large version hash (stable as of mid-2025).
  // If generation fails with 422, update this to the latest hash from:
  // https://replicate.com/meta/musicgen/versions
  static const _musicGenVersion =
      'b05b1dff1d8c6dc63d14b0cdb42135378dcb87f6942d2ffe6e8a2bef6f8b0b2e';

  /// Generates a loop via MusicGen on Replicate.
  /// Returns the CDN URL to the output MP3/WAV, or throws on error.
  Future<String> generateAudio(GenerationParams params) async {
    // Web preview can't call external APIs (CORS) — return null so caller
    // falls back to a demo loop instead of crashing.
    if (kIsWeb) throw ReplicateWebNotSupportedException();
    if (!hasApiKey) throw Exception('No Replicate API key set. Add it in Account → Connect AI.');

    final prompt = _buildPrompt(params);
    final durationSecs = _calcDuration(params.bpm, params.bars).round().clamp(5, 30);

    // Step 1 — Create prediction via the versioned predictions endpoint
    final createRes = await http.post(
      Uri.parse('https://api.replicate.com/v1/predictions'),
      headers: {
        'Authorization': 'Token $_apiKey',
        'Content-Type': 'application/json',
        'Prefer': 'wait=60',
      },
      body: jsonEncode({
        'version': _musicGenVersion,
        'input': {
          'prompt': prompt,
          'duration': durationSecs,
          'model_version': 'stereo-large',
          'output_format': 'mp3',
          'normalization_strategy': 'loudness',
        },
      }),
    );

    if (createRes.statusCode == 401) {
      throw Exception(
          'Invalid Replicate API key. Check it in Account → Connect AI.');
    }
    if (createRes.statusCode == 422) {
      // Model version hash may be stale — surface a clear message
      throw Exception(
          'Model version mismatch. Please update the app or contact support.');
    }
    if (createRes.statusCode != 200 && createRes.statusCode != 201) {
      throw Exception('Generation failed (${createRes.statusCode}). Try again.');
    }

    final created = jsonDecode(createRes.body) as Map<String, dynamic>;

    // Step 2 — Prefer: wait=60 often returns output inline in the same response
    final output = created['output'];
    if (output != null) return _extractUrl(output);

    final predId = created['id'] as String?;
    if (predId == null) throw Exception('No prediction ID returned.');

    return await _pollForResult(predId);
  }

  Future<String> _pollForResult(String predId) async {
    const maxAttempts = 30;
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 3));

      final res = await http.get(
        Uri.parse('https://api.replicate.com/v1/predictions/$predId'),
        headers: {'Authorization': 'Token $_apiKey'},
      );

      if (res.statusCode != 200) continue;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final status = body['status'] as String?;

      if (status == 'succeeded') return _extractUrl(body['output']);
      if (status == 'failed') throw Exception('Generation failed: ${body['error'] ?? 'unknown error'}');
    }
    throw Exception('Generation timed out. Please try again.');
  }

  String _extractUrl(dynamic output) {
    if (output is String) return output;
    if (output is List && output.isNotEmpty) return output.first.toString();
    throw Exception('Unexpected output format from Replicate.');
  }

  String _buildPrompt(GenerationParams params) {
    final parts = <String>[];

    if (params.prompt.isNotEmpty) {
      parts.add(params.prompt);
    }

    parts.add('${params.genre} music');
    parts.add('${params.mood} mood');
    parts.add('${params.bpm} BPM');
    if (params.instrument.isNotEmpty && params.instrument != 'Any') {
      parts.add('featuring ${params.instrument}');
    }
    parts.add('${params.key} ${params.scale}');
    parts.add('professional quality loop');
    parts.add('royalty free');

    return parts.join(', ');
  }

  double _calcDuration(int bpm, int bars) {
    return 4.0 * bars / bpm * 60.0;
  }
}

/// Sentinel thrown on web so LoopService can silently fall back to a demo loop.
class ReplicateWebNotSupportedException implements Exception {}
