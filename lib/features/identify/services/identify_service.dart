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

Your task is to identify the plant shown in the image as accurately
and scientifically as possible.

============================================================
1. VISUAL EVIDENCE ONLY
============================================================

Analyze ONLY characteristics that are actually visible in the image.

Consider:
leaf shape, leaf size, leaf texture, leaf arrangement, leaf margin,
leaf tip, leaf base, veins, petioles, stems, growth pattern,
coloration, variegation, flowers, fruits, spadix, spathe, buds,
and other clearly visible botanical characteristics.

Never assume or invent a feature that cannot be seen.

If the image shows only leaves, base your identification primarily
on leaf characteristics.

============================================================
2. SPECIES-LEVEL IDENTIFICATION
============================================================

First determine the most likely plant family or genus from the
visible characteristics.

Then determine the most likely species.

If multiple species have very similar visible characteristics,
choose the species that best matches the available evidence, but
do NOT pretend that the species is certain.

If species-level evidence is insufficient, still provide the most
likely species, but lower the confidence score.

Important:
If only leaves are visible and the plant has visually similar
species, do not give extremely high species-level confidence.

Do not use the presence of a common leaf shape alone as proof of
an exact species.

If distinctive species-level features such as flowers, fruits,
spathe, spadix, or other diagnostic structures are not visible,
consider this when assigning confidence.

============================================================
3. CONFIDENCE
============================================================

Confidence must represent visual identification confidence.

90-100 = extremely strong species-level visual evidence;
distinctive diagnostic features are clearly visible.

75-89 = strong identification; most visible characteristics match,
but some species-level uncertainty remains.

50-74 = reasonable identification; several characteristics match,
but important evidence is missing or similar species are possible.

25-49 = weak identification; limited visual evidence or substantial
similarity with other plants.

0-24 = very uncertain, not enough evidence, or the image may not
contain a recognizable plant.

Do not automatically use high confidence.

If only a leaf is visible and there are no distinctive
species-level structures, normally keep confidence below 90 unless
the visible characteristics are exceptionally distinctive.

============================================================
4. SCIENTIFIC NAME CONSISTENCY
============================================================

The common name and scientific name MUST refer to the same plant
species.

Use a scientifically valid scientific name when possible.

Do not combine the common name of one species with the scientific
name of another species.

============================================================
5. HEALTH ASSESSMENT
============================================================

Determine whether the plant appears healthy based ONLY on visible
evidence.

Healthy:
true = no obvious serious visible disease, pest damage, severe
nutrient deficiency, or major stress is visible.

Healthy:
false = obvious visible disease symptoms, significant pest damage,
severe discoloration, extensive necrosis, or serious visible stress
is present.

Important:
Do NOT diagnose an underlying cause unless the image provides
strong visible evidence.

For example, yellowing alone does NOT prove:
overwatering, underwatering, root rot, nutrient deficiency, fungal
infection, bacterial infection, or viral infection.

A visible symptom may have multiple possible causes.

============================================================
6. DESCRIPTION
============================================================

Description should explain what is visibly present in the image.

Focus on:
- distinctive plant characteristics
- visible leaf characteristics
- visible flowers or reproductive structures
- visible discoloration or damage
- other useful botanical evidence

Do not state uncertain causes as confirmed facts.

============================================================
7. CARE TIPS
============================================================

Provide practical general care advice appropriate for the identified
plant.

If the plant shows visible damage, provide sensible supportive care.

Do not claim that a specific disease, pathogen, root problem,
nutrient deficiency, or pest is confirmed unless it can reasonably
be established from visible evidence.

If the cause is uncertain, phrase the advice conservatively.

============================================================
8. NON-PLANT IMAGES
============================================================

If the image is not a plant, or there is not enough evidence to
reasonably identify a plant:

Plant Name: Unknown Plant
Scientific Name: Unknown
Confidence: 0
Description: The image does not provide sufficient evidence for reliable plant identification.
Care Tips: Unable to provide plant-specific care advice without a reliable identification.
Healthy: true

============================================================
9. OUTPUT FORMAT
============================================================

Return ONLY these six fields:

Plant Name:
Scientific Name:
Confidence:
Description:
Care Tips:
Healthy:

Strict rules:

- Do not use Markdown.
- Do not use bullet points.
- Do not add extra headings.
- Do not add explanations before or after the six fields.
- Confidence must be a number from 0 to 100.
- Do not include the % symbol in Confidence.
- Healthy must be exactly true or false.
- Keep each field on its own line.
- Description should be concise but informative.
- Care Tips should be practical and conservative.
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