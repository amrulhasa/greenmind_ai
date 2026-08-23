import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../../identify/models/identify_result.dart';
import '../models/plant_care_report.dart';

class PlantReportService {
  PlantReportService();

  // ============================================================
  // CONFIGURATION
  // ============================================================

  static const String _modelName = 'gemini-3.6-flash';

  static const int _maxOutputTokens = 2500;

  static const int _maxNetworkRetries = 1;

  // ============================================================
  // GEMINI MODEL
  // ============================================================

  late final GenerativeModel _model =
      FirebaseAI.googleAI().generativeModel(
    model: _modelName,

    generationConfig: GenerationConfig(
      temperature: 0.20,
      maxOutputTokens: _maxOutputTokens,
      responseMimeType: 'application/json',
      responseSchema: _reportSchema,
    ),

    systemInstruction: Content.system(
      '''
You are GreenMind AI.

You are an expert plant identification,
plant health observation and plant-care assistant.

Your task is to analyze the supplied plant image
and generate a useful personalized plant-care report.

CORE RULES:

1. The supplied image is the primary evidence.
2. Inspect the actual visible plant.
3. Previous identification is supporting context only.
4. Do not blindly copy previous identification.
5. Verify plant identity using visible characteristics.
6. Do not invent symptoms.
7. Analyze only visible health conditions.
8. Do not claim laboratory-level diagnosis.
9. Do not claim invisible root, internal, microscopic,
   chemical or genetic conditions.
10. Health score represents visible condition only.
11. Care recommendations must match the identified plant.
12. Recommendations must be practical for a normal plant owner.
13. Care schedule must contain realistic recurring tasks.
14. If image quality is insufficient, lower confidence.
15. If no clear health issue is visible, say the plant
    appears visually healthy.
16. Return ONLY the requested JSON structure.

Be concise but informative.
''',
    ),
  );

  // ============================================================
  // RESPONSE SCHEMA
  // ============================================================

  static final Schema _reportSchema = Schema.object(
    properties: {
      'plantName': Schema.string(),

      'scientificName': Schema.string(),

      'category': Schema.string(),

      'identificationConfidence': Schema.number(
        minimum: 0,
        maximum: 1,
      ),

      'healthStatus': Schema.string(),

      'healthScore': Schema.integer(
        minimum: 0,
        maximum: 100,
      ),

      'overview': Schema.string(),

      'sunlight': Schema.string(),

      'watering': Schema.string(),

      'soil': Schema.string(),

      'temperature': Schema.string(),

      'humidity': Schema.string(),

      'fertilizer': Schema.string(),

      'symptoms': Schema.array(
        items: Schema.string(),
        maxItems: 8,
      ),

      'recommendations': Schema.array(
        items: Schema.string(),
        maxItems: 8,
      ),

      'careSchedule': Schema.array(
        items: Schema.object(
          properties: {
            'title': Schema.string(),

            'description': Schema.string(),

            'frequency': Schema.string(),

            'icon': Schema.string(),
          },

          propertyOrdering: [
            'title',
            'description',
            'frequency',
            'icon',
          ],
        ),

        maxItems: 8,
      ),
    },

    propertyOrdering: [
      'plantName',
      'scientificName',
      'category',
      'identificationConfidence',
      'healthStatus',
      'healthScore',
      'overview',
      'sunlight',
      'watering',
      'soil',
      'temperature',
      'humidity',
      'fertilizer',
      'symptoms',
      'recommendations',
      'careSchedule',
    ],
  );

  // ============================================================
  // GENERATE REPORT
  // ============================================================

  Future<PlantCareReport> generateReportFromIdentification({
    required IdentifyResult identification,
    required Uint8List imageBytes,
    String? imagePath,
    String? imageSource,
  }) async {
    // ==========================================================
    // IMAGE VALIDATION
    // ==========================================================

    if (imageBytes.isEmpty) {
      throw const PlantReportException(
        'The plant image is empty.',
      );
    }

    // ==========================================================
    // IMAGE SIZE VALIDATION
    // ==========================================================

    // 15 MB safety limit.
    const maxImageSize = 15 * 1024 * 1024;

    if (imageBytes.length > maxImageSize) {
      throw const PlantReportException(
        'The selected image is too large. '
        'Please choose an image smaller than 15 MB.',
      );
    }

    // ==========================================================
    // MIME TYPE
    // ==========================================================

    final mimeType = _detectMimeType(imageBytes);

    final imagePart = InlineDataPart(
      mimeType,
      imageBytes,
    );

    // ==========================================================
    // PREVIOUS IDENTIFICATION
    // ==========================================================

    final previousPlantName =
        identification.plantName.trim();

    final previousScientificName =
        identification.scientificName.trim();

    final previousConfidence =
        identification.normalizedConfidence;

    final previousHealth =
        identification.isHealthy
            ? 'Appears healthy'
            : 'Possible visible health issue';

    // ==========================================================
    // PROMPT
    // ==========================================================

    final prompt = TextPart(
      '''
Generate a complete GreenMind AI plant-care report.

PREVIOUS IDENTIFICATION
-----------------------

Plant name:
$previousPlantName

Scientific name:
$previousScientificName

Previous identification confidence:
$previousConfidence

Previous visible health status:
$previousHealth


IMPORTANT
---------

The previous identification is only supporting context.

Inspect the supplied image yourself and verify the plant.

Use visible characteristics such as:

- leaf shape
- leaf arrangement
- leaf color
- leaf texture
- stem structure
- flowers if visible
- fruits if visible
- overall plant structure
- distinctive visible characteristics

Do not blindly copy the previous identification.


IDENTIFICATION CONFIDENCE
-------------------------

Return a number from 0 to 1.

0.90 - 1.00 = very strong
0.75 - 0.89 = strong
0.50 - 0.74 = moderate
below 0.50 = uncertain


HEALTH ANALYSIS
---------------

Analyze only what can actually be seen.

Look for:

- yellowing
- browning
- spots
- wilting
- curling
- holes
- discoloration
- fungal-looking visual patterns
- pest-like damage
- nutrient-deficiency-like visual symptoms
- general visible stress
- physical damage

Do not diagnose a disease with certainty unless
the visual evidence is strong.

If there is no clear visible problem,
describe the plant as visually healthy.

Do not invent symptoms.


HEALTH SCORE
------------

Return an integer from 0 to 100.

90-100 = excellent visible condition
75-89 = generally healthy
50-74 = moderate visible stress
25-49 = significant visible problems
0-24 = severe visible deterioration


CARE INFORMATION
----------------

Provide plant-specific guidance for:

1. Sunlight
2. Watering
3. Soil
4. Temperature
5. Humidity
6. Fertilizer


RECOMMENDATIONS
---------------

Provide practical recommendations that
a normal plant owner can follow.

Avoid unnecessary or dangerous treatment advice.

Only recommend actions relevant to the visible
condition and identified plant.


CARE SCHEDULE
-------------

Create realistic recurring tasks.

Possible tasks include:

- Watering
- Soil moisture check
- Sunlight check
- Fertilizing
- Leaf cleaning
- Leaf inspection
- Pest inspection
- Pruning
- Humidity check

Each task must contain:

title
description
frequency
icon

Allowed icon identifiers:

water_drop
wb_sunny
eco
science
thermostat
humidity
content_cut
bug_report

Return ONLY valid JSON.
''',
    );

    // ==========================================================
    // CONTENT
    // ==========================================================

    final content = Content.multi([
      prompt,
      imagePart,
    ]);

    // ==========================================================
    // GEMINI REQUEST
    // ==========================================================

    GenerateContentResponse? response;

    Object? lastError;

    for (
      int attempt = 0;
      attempt <= _maxNetworkRetries;
      attempt++
    ) {
      try {
        response = await _model.generateContent([
          content,
        ]);

        break;
      } catch (error) {
        lastError = error;

        // ------------------------------------------------------
        // QUOTA / RATE LIMIT
        // ------------------------------------------------------

        if (_isQuotaError(error)) {
          throw PlantReportQuotaException(
            _extractQuotaMessage(error),
          );
        }

        // ------------------------------------------------------
        // AUTHORIZATION
        // ------------------------------------------------------

        if (_isAuthorizationError(error)) {
          throw const PlantReportAuthorizationException(
            'GreenMind AI is not authorized correctly. '
            'Please check your Firebase AI configuration.',
          );
        }

        // ------------------------------------------------------
        // INVALID REQUEST
        // ------------------------------------------------------

        if (_isInvalidRequestError(error)) {
          throw PlantReportException(
            'GreenMind AI rejected the request. '
            '${_cleanException(error)}',
          );
        }

        // ------------------------------------------------------
        // RETRY NETWORK / TEMPORARY SERVER ERROR
        // ------------------------------------------------------

        if (_isRetryableError(error) &&
            attempt < _maxNetworkRetries) {
          await Future<void>.delayed(
            const Duration(seconds: 2),
          );

          continue;
        }

        break;
      }
    }

    // ==========================================================
    // REQUEST FAILED
    // ==========================================================

    if (response == null) {
      throw PlantReportException(
        _cleanException(
          lastError ??
              'Unable to contact Gemini AI.',
        ),
      );
    }

    // ==========================================================
    // RESPONSE TEXT
    // ==========================================================

    final rawText =
        response.text?.trim();

    if (rawText == null ||
        rawText.isEmpty) {
      throw const PlantReportException(
        'Gemini returned an empty plant-care report.',
      );
    }

    // ==========================================================
    // PARSE JSON
    // ==========================================================

    final json = _parseJson(rawText);

    // ==========================================================
    // BUILD REPORT
    // ==========================================================

    final report = PlantCareReport(
      plantName: _string(
        json['plantName'],
      ),

      scientificName: _string(
        json['scientificName'],
      ),

      category: _string(
        json['category'],
      ),

      identificationConfidence:
          _number(
        json['identificationConfidence'],
      ).clamp(0.0, 1.0),

      healthStatus: _string(
        json['healthStatus'],
      ),

      healthScore:
          _number(
        json['healthScore'],
      ).round().clamp(0, 100),

      overview: _string(
        json['overview'],
      ),

      sunlight: _string(
        json['sunlight'],
      ),

      watering: _string(
        json['watering'],
      ),

      soil: _string(
        json['soil'],
      ),

      temperature: _string(
        json['temperature'],
      ),

      humidity: _string(
        json['humidity'],
      ),

      fertilizer: _string(
        json['fertilizer'],
      ),

      symptoms: _stringList(
        json['symptoms'],
      ),

      recommendations: _stringList(
        json['recommendations'],
      ),

      careSchedule: _careTasks(
        json['careSchedule'],
      ),

      generatedAt: DateTime.now(),

      imagePath: imagePath,

      imageBytes: imageBytes,

      generatedFromImage: true,

      imageSource: imageSource,
    );

    // ==========================================================
    // FINAL VALIDATION
    // ==========================================================

    _validateReport(report);

    return report;
  }

  // ============================================================
  // REPORT VALIDATION
  // ============================================================

  void _validateReport(
    PlantCareReport report,
  ) {
    if (report.plantName.trim().isEmpty) {
      throw const PlantReportException(
        'AI could not determine the plant reliably.',
      );
    }

    if (report.overview.trim().isEmpty) {
      throw const PlantReportException(
        'AI returned an incomplete plant report.',
      );
    }

    if (report.healthStatus.trim().isEmpty) {
      throw const PlantReportException(
        'AI returned an incomplete health assessment.',
      );
    }
  }

  // ============================================================
  // JSON PARSER
  // ============================================================

  Map<String, dynamic> _parseJson(
    String rawText,
  ) {
    var cleaned = rawText.trim();

    // ----------------------------------------------------------
    // REMOVE MARKDOWN CODE FENCE
    // ----------------------------------------------------------

    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(
        RegExp(r'^```(?:json)?\s*'),
        '',
      );

      cleaned = cleaned.replaceFirst(
        RegExp(r'\s*```$'),
        '',
      );

      cleaned = cleaned.trim();
    }

    // ----------------------------------------------------------
    // DIRECT JSON
    // ----------------------------------------------------------

    try {
      final decoded = jsonDecode(cleaned);

      if (decoded is! Map) {
        throw const PlantReportException(
          'AI report is not a JSON object.',
        );
      }

      return Map<String, dynamic>.from(
        decoded,
      );
    } catch (_) {
      // Continue to fallback extraction.
    }

    // ----------------------------------------------------------
    // FALLBACK JSON EXTRACTION
    // ----------------------------------------------------------

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start >= 0 &&
        end > start) {
      final candidate =
          cleaned.substring(
        start,
        end + 1,
      );

      try {
        final decoded =
            jsonDecode(candidate);

        if (decoded is Map) {
          return Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {
        // Continue to final error.
      }
    }

    throw const PlantReportException(
      'Unable to parse the AI plant report.',
    );
  }

  // ============================================================
  // STRING
  // ============================================================

  String _string(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value
        .toString()
        .trim();
  }

  // ============================================================
  // NUMBER
  // ============================================================

  double _number(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ============================================================
  // STRING LIST
  // ============================================================

  List<String> _stringList(
    dynamic value,
  ) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map(
          (item) => item.toString().trim(),
        )
        .where(
          (item) => item.isNotEmpty,
        )
        .take(8)
        .toList();
  }

  // ============================================================
  // CARE TASKS
  // ============================================================

  List<CareTask> _careTasks(
    dynamic value,
  ) {
    if (value is! List) {
      return <CareTask>[];
    }

    final tasks = <CareTask>[];

    for (final item in value) {
      if (item is! Map) {
        continue;
      }

      final data =
          Map<String, dynamic>.from(
        item,
      );

      final title =
          _string(data['title']);

      if (title.isEmpty) {
        continue;
      }

      tasks.add(
        CareTask(
          title: title,

          description: _string(
            data['description'],
          ),

          frequency: _string(
            data['frequency'],
          ),

          icon: _string(
            data['icon'],
          ),
        ),
      );

      if (tasks.length >= 8) {
        break;
      }
    }

    return tasks;
  }

  // ============================================================
  // MIME TYPE
  // ============================================================

  String _detectMimeType(
    Uint8List bytes,
  ) {
    // ----------------------------------------------------------
    // JPEG
    // ----------------------------------------------------------

    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // ----------------------------------------------------------
    // PNG
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // WEBP
    // ----------------------------------------------------------

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

    throw const PlantReportException(
      'Unsupported image format. '
      'Please select a JPG, PNG or WEBP image.',
    );
  }

  // ============================================================
  // ERROR HELPERS
  // ============================================================

  String _cleanException(
    Object error,
  ) {
    var message = error.toString();

    message = message.replaceFirst(
      'PlantReportException: ',
      '',
    );

    message = message.replaceFirst(
      'Exception: ',
      '',
    );

    return message.trim();
  }

  // ============================================================
  // QUOTA DETECTION
  // ============================================================

  bool _isQuotaError(
    Object error,
  ) {
    final message =
        error.toString().toLowerCase();

    return message.contains('quota') ||
        message.contains('resource exhausted') ||
        message.contains('rate limit') ||
        message.contains('429') ||
        message.contains(
          'generate_content_free_tier_requests',
        );
  }

  // ============================================================
  // QUOTA MESSAGE
  // ============================================================

  String _extractQuotaMessage(
    Object error,
  ) {
    final message =
        error.toString();

    final retryMatch =
        RegExp(
      r'retry in\s+([\d.]+)s',
      caseSensitive: false,
    ).firstMatch(message);

    if (retryMatch != null) {
      final seconds =
          retryMatch.group(1);

      return 'Gemini AI usage limit has been reached. '
          'Please wait about $seconds seconds and try again.';
    }

    return 'Gemini AI usage limit has been reached. '
        'Please try again later.';
  }

  // ============================================================
  // AUTHORIZATION
  // ============================================================

  bool _isAuthorizationError(
    Object error,
  ) {
    final message =
        error.toString().toLowerCase();

    return message.contains(
          'permission-denied',
        ) ||
        message.contains(
          'permission denied',
        ) ||
        message.contains(
          'unauthenticated',
        ) ||
        message.contains(
          'authentication',
        ) ||
        message.contains(
          'unauthorized',
        );
  }

  // ============================================================
  // INVALID REQUEST
  // ============================================================

  bool _isInvalidRequestError(
    Object error,
  ) {
    final message =
        error.toString().toLowerCase();

    return message.contains(
          'invalid argument',
        ) ||
        message.contains(
          'invalid request',
        ) ||
        message.contains(
          'bad request',
        );
  }

  // ============================================================
  // RETRYABLE ERROR
  // ============================================================

  bool _isRetryableError(
    Object error,
  ) {
    final message =
        error.toString().toLowerCase();

    return message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('socket') ||
        message.contains('connection') ||
        message.contains('network') ||
        message.contains('503') ||
        message.contains('502') ||
        message.contains('500');
  }
}

// ================================================================
// BASE EXCEPTION
// ================================================================

class PlantReportException
    implements Exception {
  final String message;

  const PlantReportException(
    this.message,
  );

  @override
  String toString() {
    return 'PlantReportException: $message';
  }
}

// ================================================================
// QUOTA EXCEPTION
// ================================================================

class PlantReportQuotaException
    extends PlantReportException {
  const PlantReportQuotaException(
    super.message,
  );
}

// ================================================================
// AUTHORIZATION EXCEPTION
// ================================================================

class PlantReportAuthorizationException
    extends PlantReportException {
  const PlantReportAuthorizationException(
    super.message,
  );
}