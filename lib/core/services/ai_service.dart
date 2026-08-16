import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../../features/identify/models/identify_result.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    final firebaseAI = FirebaseAI.googleAI();

    _model = firebaseAI.generativeModel(model: 'gemini-2.5-flash');
  }

  Future<IdentifyResult> identifyPlant(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final prompt = TextPart('''
You are a plant identification assistant.

Analyze the provided plant image carefully.

Return ONLY valid JSON.
Do not use markdown.
Do not add any explanation outside the JSON.

Use exactly this structure:

{
  "plantName": "Common plant name",
  "scientificName": "Scientific name",
  "confidence": 0.95,
  "description": "Short description of the plant",
  "careTips": "Short and useful care instructions",
  "isHealthy": true
}

Rules:
- confidence must be a number between 0 and 1.
- isHealthy must be true or false.
- If you cannot confidently identify the plant, use the most likely identification and lower the confidence.
- If the image is not a plant, use:
  "plantName": "Not a plant"
- Keep description and careTips concise.
''');

    final imagePart = InlineDataPart(mimeType, imageBytes);

    final response = await _model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('AI returned an empty response.');
    }

    return _parseResult(text);
  }

  IdentifyResult _parseResult(String response) {
    var cleaned = response.trim();

    // Remove markdown code fences if the model adds them.
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');

      cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');
    }

    final json = jsonDecode(cleaned) as Map<String, dynamic>;

    return IdentifyResult(
      plantName: json['plantName']?.toString() ?? '',
      scientificName: json['scientificName']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      careTips: json['careTips']?.toString() ?? '',
      isHealthy: json['isHealthy'] as bool? ?? true,
    );
  }
}
