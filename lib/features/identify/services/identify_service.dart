import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/identify_result.dart';

class IdentifyService {
  IdentifyService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
    );
  }

  late final GenerativeModel _model;

  Future<IdentifyResult> identifyPlant(Uint8List imageBytes) async {
    final prompt = TextPart(
      '''
You are a professional botanist and plant identification expert.

Your task is to identify the plant shown in the image as accurately as possible.

IMPORTANT IDENTIFICATION RULES:

1. Carefully analyze the visible plant morphology before deciding:
   - leaf shape
   - leaf size
   - leaf texture
   - leaf arrangement
   - veins
   - stems and petioles
   - growth pattern
   - coloration
   - variegation
   - visible flowers or fruits
   - other distinctive characteristics

2. Compare the visual characteristics with likely plant species.

3. Do NOT identify a plant only because it looks generally similar to another
   common plant.

4. If multiple species are visually similar, choose the species that best
   matches the visible characteristics.

5. Do not invent flowers, fruits, stems, or other features that are not visible
   in the image.

6. If the image does not provide enough information for reliable species-level
   identification, use a lower confidence score.

7. Confidence must represent how certain you are based ONLY on the image:
   - 90-100 = extremely strong visual match
   - 75-89 = strong match
   - 50-74 = reasonable but uncertain
   - below 50 = weak identification

8. Keep the common plant name and scientific name consistent.
   Do not give different common names for the same scientific species.

9. For health status, only mark Healthy as false when there are visible signs
   of disease, pest damage, severe nutrient deficiency, or serious plant stress.
   Minor natural leaf splitting or small physical damage should not automatically
   be considered unhealthy.

10. If the image is not actually a plant or cannot reasonably be identified,
    clearly say that identification is uncertain and use a low confidence score.

Return ONLY the following fields.

Plant Name:
Scientific Name:
Confidence:
Description:
Care Tips:
Healthy:

OUTPUT RULES:

- Do not use Markdown.
- Do not use bullet points.
- Do not add headings.
- Do not add explanations outside these fields.
- Confidence must be a number from 0 to 100.
- Healthy must be exactly true or false.
- Description should briefly explain the visual characteristics that support
  the identification.
- Care Tips should provide practical care advice appropriate for the identified
  plant.
''',
    );

    final imagePart = InlineDataPart(
      'image/jpeg',
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
      throw Exception('AI returned an empty response.');
    }

    return _parseResult(text);
  }

  IdentifyResult _parseResult(String text) {
    final cleanedText = text
        .replaceAll('```text', '')
        .replaceAll('```', '')
        .trim();

    String getValue(String label) {
      final lines = cleanedText.split('\n');

      final labelLower = label.toLowerCase();

      for (final line in lines) {
        final trimmedLine = line.trim();
        final lowerLine = trimmedLine.toLowerCase();

        if (lowerLine.startsWith('$labelLower:')) {
          return trimmedLine
              .substring(label.length + 1)
              .trim();
        }
      }

      return '';
    }

    final plantName = getValue('Plant Name');
    final scientificName = getValue('Scientific Name');
    final confidenceText = getValue('Confidence');
    final description = getValue('Description');
    final careTips = getValue('Care Tips');
    final healthyText = getValue('Healthy');

    double confidence = double.tryParse(
          confidenceText
              .replaceAll('%', '')
              .trim(),
        ) ??
        0;

    confidence = confidence.clamp(0.0, 100.0);

    final normalizedHealthy = healthyText
        .toLowerCase()
        .trim();

    final isHealthy = normalizedHealthy == 'true';

    if (plantName.isEmpty && scientificName.isEmpty) {
      throw Exception(
        'AI response could not be parsed.',
      );
    }

    return IdentifyResult(
      plantName: plantName,
      scientificName: scientificName,
      confidence: confidence,
      description: description,
      careTips: careTips,
      isHealthy: isHealthy,
    );
  }
}