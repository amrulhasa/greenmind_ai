import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/identify_result.dart';

class IdentifyService {
  IdentifyService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
    );
  }

  late final GenerativeModel _model;

  // ============================================================
  // IDENTIFY PLANT
  // ============================================================

  Future<IdentifyResult> identifyPlant(
    Uint8List imageBytes,
  ) async {
    if (imageBytes.isEmpty) {
      throw Exception(
        'Image data is empty.',
      );
    }

    final prompt = TextPart(
      '''
You are a professional botanist and plant identification expert.

Identify the plant shown in the image as accurately as possible.

Analyze ONLY visible evidence, including:
leaf shape, leaf size, leaf texture, leaf arrangement, veins,
stems, petioles, growth pattern, coloration, variegation,
flowers, fruits, and other visible characteristics.

Do not invent features that are not visible.

If multiple species are visually similar, select the species
that best matches the visible characteristics.

If there is not enough visual evidence for reliable species-level
identification, use a lower confidence score.

Confidence rules:
90-100 = extremely strong visual match
75-89 = strong match
50-74 = reasonable but uncertain
0-49 = weak identification

The common name and scientific name must refer to the same species.

For health status:
true = plant appears healthy from visible evidence
false = visible disease, pest damage, severe deficiency,
or serious stress is present.

If the image is not a plant or cannot reasonably be identified,
use a low confidence score and explain that identification is uncertain.

Return ONLY these six fields:

Plant Name:
Scientific Name:
Confidence:
Description:
Care Tips:
Healthy:

Rules:
- Do not use Markdown.
- Do not use bullet points.
- Do not add extra headings.
- Confidence must be a number from 0 to 100.
- Healthy must be exactly true or false.
- Description should briefly explain visible evidence.
- Care Tips should provide practical care advice.
- Keep each field on its own line.
''',
    );

    final imagePart = InlineDataPart(
      _detectMimeType(imageBytes),
      imageBytes,
    );

    final response = await _model.generateContent([
      Content.multi([
        prompt,
        imagePart,
      ]),
    ]);

    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception(
        'AI returned an empty response.',
      );
    }

    return _parseResult(text);
  }

  // ============================================================
  // MIME TYPE DETECTION
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

    // Fallback
    return 'image/jpeg';
  }

  // ============================================================
  // PARSE AI RESULT
  // ============================================================

  IdentifyResult _parseResult(
    String text,
  ) {
    final cleanedText = text
        .replaceAll('```text', '')
        .replaceAll('```plaintext', '')
        .replaceAll('```', '')
        .trim();

    final values = <String, String>{};

    String? currentKey;

    for (final rawLine in cleanedText.split('\n')) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      final separatorIndex = line.indexOf(':');

      // --------------------------------------------------------
      // FIELD LINE
      // --------------------------------------------------------

      if (separatorIndex > 0) {
        final rawKey = line
            .substring(
              0,
              separatorIndex,
            )
            .trim()
            .toLowerCase();

        final value = line
            .substring(
              separatorIndex + 1,
            )
            .trim();

        final normalizedKey = _normalizeKey(
          rawKey,
        );

        if (_isSupportedKey(
          normalizedKey,
        )) {
          values[normalizedKey] = value;
          currentKey = normalizedKey;
          continue;
        }
      }

      // --------------------------------------------------------
      // MULTI-LINE DESCRIPTION / CARE TIPS
      // --------------------------------------------------------

      if (currentKey != null &&
          (currentKey == 'description' ||
              currentKey == 'care tips')) {
        final String key = currentKey;

        final previous = values[key] ?? '';

        values[key] = previous.isEmpty
            ? line
            : '$previous $line';
      }
    }

    // ==========================================================
    // EXTRACT VALUES
    // ==========================================================

    final plantName =
        values['plant name']?.trim() ?? '';

    final scientificName =
        values['scientific name']?.trim() ?? '';

    final confidenceText =
        values['confidence']?.trim() ?? '0';

    final description =
        values['description']?.trim() ?? '';

    final careTips =
        values['care tips']?.trim() ?? '';

    final healthyText =
        values['healthy']?.trim() ?? '';

    // ==========================================================
    // CONFIDENCE
    // ==========================================================

    var confidence = _parseConfidence(
      confidenceText,
    );

    confidence = confidence.clamp(
      0.0,
      100.0,
    );

    // ==========================================================
    // HEALTH
    // ==========================================================

    final isHealthy = _parseHealth(
      healthyText,
    );

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (plantName.isEmpty &&
        scientificName.isEmpty) {
      throw Exception(
        'AI response could not be parsed.',
      );
    }

    return IdentifyResult(
      plantName: plantName.isEmpty
          ? 'Unknown Plant'
          : plantName,
      scientificName: scientificName,
      confidence: confidence,
      description: description,
      careTips: careTips,
      isHealthy: isHealthy,
    );
  }

  // ============================================================
  // CONFIDENCE PARSER
  // ============================================================

  double _parseConfidence(
    String value,
  ) {
    final cleaned = value
        .replaceAll('%', '')
        .trim();

    return double.tryParse(
          cleaned,
        ) ??
        0;
  }

  // ============================================================
  // HEALTH PARSER
  // ============================================================

  bool _parseHealth(
    String value,
  ) {
    final normalized = value
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z]'),
          '',
        );

    return normalized == 'true';
  }

  // ============================================================
  // NORMALIZE KEY
  // ============================================================

  String _normalizeKey(
    String key,
  ) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }

  // ============================================================
  // SUPPORTED KEYS
  // ============================================================

  bool _isSupportedKey(
    String key,
  ) {
    return key == 'plant name' ||
        key == 'scientific name' ||
        key == 'confidence' ||
        key == 'description' ||
        key == 'care tips' ||
        key == 'healthy';
  }
}