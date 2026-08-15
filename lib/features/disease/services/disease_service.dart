import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/disease_result.dart';

class DiseaseService {
  DiseaseService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
    );
  }

  late final GenerativeModel _model;

  static const String _cacheKey = 'greenmind_disease_cache';

  Map<String, DiseaseResult> _cache = {};

  bool _initialized = false;

  // ============================================================
  // INITIALIZE PERSISTENT CACHE
  // ============================================================

  Future<void> _initializeCache() async {
    if (_initialized) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final savedCache = prefs.getString(_cacheKey);

      if (savedCache != null && savedCache.isNotEmpty) {
        final Map<String, dynamic> decoded =
            jsonDecode(savedCache) as Map<String, dynamic>;

        final Map<String, DiseaseResult> loadedCache = {};

        for (final entry in decoded.entries) {
          try {
            final value = entry.value;

            if (value is Map<String, dynamic>) {
              loadedCache[entry.key] =
                  DiseaseResult.fromJson(value);
            } else if (value is Map) {
              loadedCache[entry.key] =
                  DiseaseResult.fromJson(
                Map<String, dynamic>.from(value),
              );
            }
          } catch (e) {
            debugPrint(
              'Could not load cached result for ${entry.key}: $e',
            );
          }
        }

        _cache = loadedCache;

        debugPrint('==============================');
        debugPrint('PERSISTENT CACHE INITIALIZED');
        debugPrint('Cached results: ${_cache.length}');
        debugPrint('==============================');
      } else {
        debugPrint('==============================');
        debugPrint('PERSISTENT CACHE EMPTY');
        debugPrint('==============================');
      }
    } catch (e, stackTrace) {
      debugPrint('==============================');
      debugPrint('CACHE INITIALIZATION ERROR');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('==============================');

      _cache = {};
    }

    _initialized = true;
  }

  // ============================================================
  // SAVE CACHE
  // ============================================================

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> encodedCache = {};

      for (final entry in _cache.entries) {
        encodedCache[entry.key] = entry.value.toJson();
      }

      await prefs.setString(
        _cacheKey,
        jsonEncode(encodedCache),
      );

      debugPrint('==============================');
      debugPrint('PERSISTENT CACHE SAVED');
      debugPrint('Cached results: ${_cache.length}');
      debugPrint('==============================');
    } catch (e, stackTrace) {
      debugPrint('==============================');
      debugPrint('CACHE SAVE ERROR');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('==============================');
    }
  }

  // ============================================================
  // DETECT DISEASE
  // ============================================================

  Future<DiseaseResult> detectDisease(
    Uint8List imageBytes,
  ) async {
    // ----------------------------------------------------------
    // 1. Initialize persistent cache first
    // ----------------------------------------------------------

    await _initializeCache();

    // ----------------------------------------------------------
    // 2. Generate SHA-256 hash
    // ----------------------------------------------------------

    final imageHash =
        sha256.convert(imageBytes).toString();

    debugPrint('==============================');
    debugPrint('IMAGE HASH');
    debugPrint(imageHash);
    debugPrint('==============================');

    // ----------------------------------------------------------
    // 3. Check persistent cache
    // ----------------------------------------------------------

    final cachedResult = _cache[imageHash];

    if (cachedResult != null) {
      debugPrint('==============================');
      debugPrint('PERSISTENT CACHE HIT');
      debugPrint('Using saved detection result.');
      debugPrint(
        'Disease: ${cachedResult.diseaseName}',
      );
      debugPrint(
        'Confidence: ${cachedResult.confidence}',
      );
      debugPrint('==============================');

      return cachedResult;
    }

    // ----------------------------------------------------------
    // 4. Cache miss
    // ----------------------------------------------------------

    debugPrint('==============================');
    debugPrint('PERSISTENT CACHE MISS');
    debugPrint('Sending image to Gemini...');
    debugPrint('==============================');

    // ----------------------------------------------------------
    // 5. Prompt
    // ----------------------------------------------------------

    final prompt = TextPart(
      '''
You are an expert plant health and disease analysis assistant.

Analyze the provided plant image carefully.

Your task is to determine whether the visible plant appears healthy
or shows signs of disease, infection, pest damage, nutrient deficiency,
or other significant health problems.

IMPORTANT RULES:

1. Analyze ONLY what is visually supported by the image.

2. Carefully examine:
leaf color
spots
lesions
discoloration
holes
curling
wilting
mold or fungal-looking growth
pest damage
unusual patterns
stem condition
overall plant appearance

3. Do NOT invent symptoms that are not visible.

4. Minor natural leaf splitting, small tears, dry edges, or mechanical
damage should NOT automatically be classified as disease.

5. If the plant appears healthy, use:

Disease Name: Healthy Plant

6. If a disease or health problem is suspected, provide the most likely
condition based on visible evidence.

7. If the image is unclear or there is not enough evidence to identify
a specific disease:

clearly mention the uncertainty
use a lower confidence score
avoid claiming a definitive diagnosis

8. Confidence must realistically reflect the visual evidence:

90-100 = very strong visual evidence
75-89 = strong indication
50-74 = possible but uncertain
below 50 = weak indication

9. Do NOT provide a confidence score above 90 unless strong visual
evidence supports the diagnosis.

10. Treatment advice must be practical and general.
Do not recommend dangerous chemicals or unsafe applications.

11. Prevention advice should focus on safe plant-care practices such as:
proper watering, light, airflow, sanitation, removing affected leaves,
and monitoring the plant.

12. Compare the visible symptoms against possible disease patterns
before selecting the most likely condition.

13. Do not claim a specific pathogen or disease when the image does not
provide enough visual evidence.

Return ONLY these fields:

Disease Name:
Confidence:
Description:
Symptoms:
Treatment:
Prevention:
Healthy:

OUTPUT RULES:

Do not use Markdown.
Do not use bullet points.
Do not add extra fields.
Confidence must be a number from 0 to 100.
Healthy must be exactly true or false.
Description should explain what is visible in the image.
Symptoms should describe only visible symptoms.
Treatment should provide practical care guidance.
Prevention should provide practical prevention guidance.
''',
    );

    // ----------------------------------------------------------
    // 6. Image
    // ----------------------------------------------------------

    final imagePart = InlineDataPart(
      'image/jpeg',
      imageBytes,
    );

    try {
      // --------------------------------------------------------
      // 7. Gemini request
      // --------------------------------------------------------

      final response = await _model.generateContent([
        Content.multi([
          prompt,
          imagePart,
        ]),
      ]);

      final text = response.text;

      debugPrint('==============================');
      debugPrint('GREENMIND DISEASE AI RESPONSE');
      debugPrint('==============================');
      debugPrint(text ?? 'NULL RESPONSE');
      debugPrint('==============================');

      if (text == null || text.trim().isEmpty) {
        throw Exception(
          'AI returned an empty response.',
        );
      }

      // --------------------------------------------------------
      // 8. Parse result
      // --------------------------------------------------------

      final result = _parseResult(text);

      // --------------------------------------------------------
      // 9. Save result to memory cache
      // --------------------------------------------------------

      _cache[imageHash] = result;

      // --------------------------------------------------------
      // 10. Save result permanently
      // --------------------------------------------------------

      await _saveCache();

      debugPrint('==============================');
      debugPrint('RESULT SAVED TO PERSISTENT CACHE');
      debugPrint(
        'Disease: ${result.diseaseName}',
      );
      debugPrint(
        'Confidence: ${result.confidence}',
      );
      debugPrint('==============================');

      return result;
    } catch (e, stackTrace) {
      debugPrint('==============================');
      debugPrint('DISEASE AI ERROR');
      debugPrint('==============================');
      debugPrint(e.toString());
      debugPrint('------------------------------');
      debugPrint(stackTrace.toString());
      debugPrint('==============================');

      rethrow;
    }
  }

  // ============================================================
  // ROBUST MULTILINE PARSER
  // ============================================================

  DiseaseResult _parseResult(String text) {
    String cleanedText = text
        .replaceAll('```text', '')
        .replaceAll('```', '')
        .trim();

    final labels = <String>[
      'Disease Name:',
      'Confidence:',
      'Description:',
      'Symptoms:',
      'Treatment:',
      'Prevention:',
      'Healthy:',
    ];

    for (final label in labels) {
      cleanedText = cleanedText.replaceAll(
        RegExp(
          RegExp.escape(label),
          caseSensitive: false,
        ),
        '\n$label',
      );
    }

    final lines = cleanedText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final Map<String, String> values = {};

    String? currentLabel;

    for (final line in lines) {
      final lower = line.toLowerCase();

      String? matchedLabel;

      for (final label in labels) {
        if (lower.startsWith(label.toLowerCase())) {
          matchedLabel = label;
          break;
        }
      }

      if (matchedLabel != null) {
        currentLabel = matchedLabel;

        final colonIndex = line.indexOf(':');

        if (colonIndex != -1) {
          values[currentLabel] =
              line.substring(colonIndex + 1).trim();
        }
      } else if (currentLabel != null) {
        values[currentLabel] =
            '${values[currentLabel] ?? ''} $line'.trim();
      }
    }

    final diseaseName =
        values['Disease Name:']?.trim() ?? '';

    final confidenceText =
        values['Confidence:']?.trim() ?? '';

    final description =
        values['Description:']?.trim() ?? '';

    final symptoms =
        values['Symptoms:']?.trim() ?? '';

    final treatment =
        values['Treatment:']?.trim() ?? '';

    final prevention =
        values['Prevention:']?.trim() ?? '';

    final healthyText =
        values['Healthy:']?.trim() ?? '';

    double confidence =
        double.tryParse(
              confidenceText
                  .replaceAll('%', '')
                  .trim(),
            ) ??
            0;

    confidence = confidence.clamp(
      0.0,
      100.0,
    );

    final isHealthy =
        healthyText.toLowerCase() == 'true';

    if (diseaseName.isEmpty) {
      throw Exception(
        'AI response could not be parsed.',
      );
    }

    return DiseaseResult(
      diseaseName: diseaseName,
      confidence: confidence,
      description: description,
      symptoms: symptoms,
      treatment: treatment,
      prevention: prevention,
      isHealthy: isHealthy,
    );
  }

  // ============================================================
  // CLEAR ALL CACHE
  // ============================================================

  Future<void> clearCache() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove(_cacheKey);

      _cache.clear();

      _initialized = false;

      debugPrint('==============================');
      debugPrint('PERSISTENT CACHE CLEARED');
      debugPrint('==============================');
    } catch (e) {
      debugPrint(
        'CACHE CLEAR ERROR: $e',
      );
    }
  }

  // ============================================================
  // CACHE COUNT
  // ============================================================

  Future<int> getCacheCount() async {
    await _initializeCache();

    return _cache.length;
  }
}