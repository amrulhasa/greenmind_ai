import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/disease_result.dart';

class DiseaseService {
  DiseaseService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
    );
  }

  late final GenerativeModel _model;

  static const String _cacheKey =
      'greenmind_disease_cache';

  Map<String, DiseaseResult> _cache = {};

  bool _initialized = false;

  // ============================================================
  // INITIALIZE CACHE
  // ============================================================

  Future<void> _initializeCache() async {
    if (_initialized) {
      return;
    }

    try {
      final prefs =
          await SharedPreferences.getInstance();

      final savedCache =
          prefs.getString(_cacheKey);

      if (savedCache == null ||
          savedCache.isEmpty) {
        _cache = {};
        _initialized = true;
        return;
      }

      final decoded =
          jsonDecode(savedCache);

      if (decoded is! Map) {
        _cache = {};
        _initialized = true;
        return;
      }

      final loadedCache =
          <String, DiseaseResult>{};

      for (final entry
          in Map<String, dynamic>.from(decoded)
              .entries) {
        try {
          final value = entry.value;

          if (value is Map) {
            loadedCache[entry.key] =
                DiseaseResult.fromJson(
              Map<String, dynamic>.from(value),
            );
          }
        } catch (e) {
          debugPrint(
            'Could not load cached result '
            'for ${entry.key}: $e',
          );
        }
      }

      _cache = loadedCache;
    } catch (e, stackTrace) {
      debugPrint(
        'CACHE INITIALIZATION ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _cache = {};
    }

    _initialized = true;
  }

  // ============================================================
  // SAVE CACHE
  // ============================================================

  Future<void> _saveCache() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final encodedCache =
          <String, dynamic>{};

      for (final entry in _cache.entries) {
        encodedCache[entry.key] =
            entry.value.toJson();
      }

      await prefs.setString(
        _cacheKey,
        jsonEncode(encodedCache),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'CACHE SAVE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    }
  }

  // ============================================================
  // DETECT DISEASE
  // ============================================================

  Future<DiseaseResult> detectDisease(
    Uint8List imageBytes,
  ) async {
    if (imageBytes.isEmpty) {
      throw Exception(
        'Image data is empty.',
      );
    }

    // ----------------------------------------------------------
    // INITIALIZE CACHE
    // ----------------------------------------------------------

    await _initializeCache();

    // ----------------------------------------------------------
    // GENERATE IMAGE HASH
    // ----------------------------------------------------------

    final imageHash =
        sha256.convert(imageBytes).toString();

    debugPrint(
      'Disease image hash: $imageHash',
    );

    // ----------------------------------------------------------
    // CHECK CACHE
    // ----------------------------------------------------------

    final cachedResult =
        _cache[imageHash];

    if (cachedResult != null) {
      debugPrint(
        'Disease cache hit.',
      );

      return cachedResult;
    }

    debugPrint(
      'Disease cache miss. Calling Gemini...',
    );

    // ----------------------------------------------------------
    // PROMPT
    // ----------------------------------------------------------

    final prompt = TextPart(
      '''
You are an expert plant health and disease analysis assistant.

Analyze the provided plant image carefully.

Determine whether the visible plant appears healthy or shows signs of:
disease, infection, pest damage, nutrient deficiency, or serious stress.

Analyze ONLY what is visually supported by the image.

Carefully examine:
leaf color, spots, lesions, discoloration, holes, curling,
wilting, fungal-looking growth, pest damage, unusual patterns,
stem condition, and overall plant appearance.

Do not invent symptoms that are not visible.

Minor natural leaf splitting, small tears, dry edges, or mechanical
damage should not automatically be classified as disease.

If the plant appears healthy, use:
Disease Name: Healthy Plant

If a disease or health problem is suspected, provide the most likely
condition based only on visible evidence.

If the image is unclear or there is not enough evidence to identify
a specific disease, clearly mention uncertainty and use a lower
confidence score.

Confidence rules:
90-100 = very strong visual evidence
75-89 = strong indication
50-74 = possible but uncertain
0-49 = weak indication

Do not provide confidence above 90 unless strong visual evidence
supports the conclusion.

Treatment advice must be practical and general.

Do not recommend dangerous chemicals or unsafe applications.

Prevention advice should focus on safe practices such as:
proper watering, suitable light, airflow, sanitation,
removing affected leaves, and monitoring the plant.

Do not claim a specific pathogen when the image does not provide
enough visual evidence.

Return ONLY these seven fields:

Disease Name:
Confidence:
Description:
Symptoms:
Treatment:
Prevention:
Healthy:

Rules:
- Do not use Markdown.
- Do not use bullet points.
- Do not add extra fields.
- Confidence must be a number from 0 to 100.
- Healthy must be exactly true or false.
- Description should explain visible evidence.
- Symptoms should describe only visible symptoms.
- Treatment should provide practical care guidance.
- Prevention should provide practical prevention guidance.
- Keep each field on its own line.
''',
    );

    // ----------------------------------------------------------
    // IMAGE
    // ----------------------------------------------------------

    final imagePart = InlineDataPart(
      _detectMimeType(imageBytes),
      imageBytes,
    );

    try {
      // --------------------------------------------------------
      // GEMINI REQUEST
      // --------------------------------------------------------

      final response =
          await _model.generateContent([
        Content.multi([
          prompt,
          imagePart,
        ]),
      ]);

      final String? responseText =
          response.text;

      debugPrint(
        '==============================',
      );

      debugPrint(
        'GREENMIND DISEASE AI RESPONSE',
      );

      debugPrint(
        responseText ?? 'NULL RESPONSE',
      );

      debugPrint(
        '==============================',
      );

      if (responseText == null ||
          responseText.trim().isEmpty) {
        throw Exception(
          'AI returned an empty response.',
        );
      }

      // --------------------------------------------------------
      // PARSE
      // --------------------------------------------------------

      final result =
          _parseResult(responseText);

      // --------------------------------------------------------
      // SAVE CACHE
      // --------------------------------------------------------

      _cache[imageHash] = result;

      await _saveCache();

      debugPrint(
        'Disease result saved to cache.',
      );

      return result;
    } catch (e, stackTrace) {
      debugPrint(
        '==============================',
      );

      debugPrint(
        'DISEASE AI ERROR',
      );

      debugPrint(
        '$e',
      );

      debugPrint(
        '$stackTrace',
      );

      debugPrint(
        '==============================',
      );

      rethrow;
    }
  }

  // ============================================================
  // MIME TYPE
  // ============================================================

  String _detectMimeType(
    Uint8List bytes,
  ) {
    // JPEG
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // PNG
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }

    // GIF
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'image/gif';
    }

    // WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  // ============================================================
  // PARSE AI RESULT
  // ============================================================

  DiseaseResult _parseResult(
    String text,
  ) {
    var cleanedText = text
        .replaceAll('```text', '')
        .replaceAll('```plaintext', '')
        .replaceAll('```', '')
        .trim();

    const labels = [
      'Disease Name:',
      'Confidence:',
      'Description:',
      'Symptoms:',
      'Treatment:',
      'Prevention:',
      'Healthy:',
    ];

    // ----------------------------------------------------------
    // Normalize field labels
    // ----------------------------------------------------------

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
        .map(
          (line) => line.trim(),
        )
        .where(
          (line) => line.isNotEmpty,
        )
        .toList();

    final values =
        <String, String>{};

    String? currentLabel;

    // ----------------------------------------------------------
    // Read fields
    // ----------------------------------------------------------

    for (final line in lines) {
      final lowerLine =
          line.toLowerCase();

      String? matchedLabel;

      for (final label in labels) {
        if (lowerLine.startsWith(
          label.toLowerCase(),
        )) {
          matchedLabel = label;
          break;
        }
      }

      if (matchedLabel != null) {
        currentLabel = matchedLabel;

        final colonIndex =
            line.indexOf(':');

        if (colonIndex >= 0) {
          values[currentLabel] =
              line
                  .substring(
                    colonIndex + 1,
                  )
                  .trim();
        }
      } else if (currentLabel != null) {
        final previous =
            values[currentLabel] ?? '';

        values[currentLabel] =
            previous.isEmpty
                ? line
                : '$previous $line';
      }
    }

    // ----------------------------------------------------------
    // Extract values
    // ----------------------------------------------------------

    final diseaseName =
        values['Disease Name:']
                ?.trim() ??
            '';

    final confidenceText =
        values['Confidence:']
                ?.trim() ??
            '0';

    final description =
        values['Description:']
                ?.trim() ??
            '';

    final symptoms =
        values['Symptoms:']
                ?.trim() ??
            '';

    final treatment =
        values['Treatment:']
                ?.trim() ??
            '';

    final prevention =
        values['Prevention:']
                ?.trim() ??
            '';

    final healthyText =
        values['Healthy:']
                ?.trim() ??
            '';

    // ----------------------------------------------------------
    // Parse confidence
    // ----------------------------------------------------------

    var confidence =
        double.tryParse(
              confidenceText
                  .replaceAll('%', '')
                  .trim(),
            ) ??
            0.0;

    confidence =
        confidence.clamp(
      0.0,
      100.0,
    );

    // ----------------------------------------------------------
    // Parse health
    // ----------------------------------------------------------

    final normalizedHealthy =
        healthyText
            .toLowerCase()
            .replaceAll(
              RegExp(r'[^a-z]'),
              '',
            )
            .trim();

    final isHealthy =
        normalizedHealthy == 'true';

    // ----------------------------------------------------------
    // Validate
    // ----------------------------------------------------------

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
  // CLEAR CACHE
  // ============================================================

  Future<void> clearCache() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove(_cacheKey);

      _cache.clear();

      _initialized = false;

      debugPrint(
        'Disease cache cleared.',
      );
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