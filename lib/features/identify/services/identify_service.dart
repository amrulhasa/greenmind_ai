import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:logger/logger.dart';

import '../models/identify_result.dart';

class IdentifyService {
  final Logger _logger = Logger();

  IdentifyService();

  // ============================================================
  // CONFIGURATION
  // ============================================================

  static const String _modelName =
      'gemini-3.6-flash';

  static const int _maxAttempts = 2;

  static const Duration _retryDelay =
      Duration(seconds: 3);

  // ============================================================
  // GEMINI MODEL
  // ============================================================

  late final GenerativeModel _model =
      FirebaseAI.googleAI().generativeModel(
    model: _modelName,

    generationConfig:
        GenerationConfig(
      responseMimeType:
          'application/json',

      responseSchema:
          _identifySchema,

      temperature: 0.15,

      maxOutputTokens: 1200,
    ),

    systemInstruction:
        Content.text(
      '''
You are GreenMind AI, an expert botanical visual analysis assistant.

Your job is to identify plants from photographs and assess only
their visibly observable condition.

IDENTIFICATION RULES

1. The attached image is the primary evidence.

2. Never return a hardcoded plant name.

3. Never assume a plant species without visual evidence.

4. Do not identify a plant merely because it is common.

5. If the image does not clearly contain a plant:
   - return an empty plantName
   - return an empty scientificName
   - return confidence 0

6. If species-level identification is uncertain:
   - use the most defensible common-level identification
   - reduce confidence appropriately

7. Never invent a scientific name.

8. Confidence must represent visual identification confidence.

9. Health assessment must be based ONLY on visible evidence.

10. Do not claim:
    - laboratory diagnosis
    - microscopic diagnosis
    - genetic identification
    - root-level diagnosis
    - internal plant condition
    - definitive disease diagnosis

11. Care recommendations must be appropriate for the identified
    plant and must not contradict visible evidence.

12. If visual evidence is insufficient, explicitly indicate
    insufficient evidence.

13. Do not use static or predefined answers.

14. Return ONLY JSON matching the supplied response schema.

HEALTH RULES

Only assess visible characteristics such as:

- discoloration
- yellowing
- browning
- wilting
- holes
- spots
- damaged leaves
- visible pests
- fungal-like surface symptoms
- abnormal leaf shape
- visible stress

Do not claim a definitive disease unless the image provides
strong enough evidence.

OUTPUT RULES

Keep descriptions useful but concise.

Care tips should be practical.

Scientific name should only be provided when sufficiently
supported by the visual evidence.

If identification is unreliable, confidence must be low.
''',
    ),
  );

  // ============================================================
  // RESPONSE SCHEMA
  // ============================================================

  static final Schema _identifySchema =
      Schema.object(
    properties: {
      'plantName':
          Schema.string(
        description:
            'Common name of the visually identified plant. '
            'Return empty string when identification is unreliable.',
      ),

      'scientificName':
          Schema.string(
        description:
            'Scientific name only when sufficiently supported '
            'by visual evidence. Otherwise return empty string.',
      ),

      'confidence':
          Schema.number(
        minimum: 0,
        maximum: 100,
        description:
            'Visual identification confidence from 0 to 100.',
      ),

      'description':
          Schema.string(
        description:
            'Concise description of visible plant characteristics.',
      ),

      'careTips':
          Schema.string(
        description:
            'Practical general care guidance appropriate for '
            'the identified plant.',
      ),

      'isHealthy':
          Schema.boolean(
        description:
            'True when no significant visible health problem '
            'is detected.',
      ),
    },

    propertyOrdering: [
      'plantName',
      'scientificName',
      'confidence',
      'description',
      'careTips',
      'isHealthy',
    ],
  );

  // ============================================================
  // IDENTIFY PLANT
  // ============================================================

  Future<IdentifyResult> identifyPlant(
    Uint8List imageBytes,
  ) async {
    if (imageBytes.isEmpty) {
      throw const IdentifyException(
        IdentifyErrorType.invalidImage,
        'Image data is empty.',
      );
    }

    final String mimeType =
        _detectMimeType(imageBytes);

    final InlineDataPart imagePart =
        InlineDataPart(
      mimeType,
      imageBytes,
    );

    final TextPart prompt =
        TextPart(
      '''
Analyze this plant photograph for GreenMind AI.

Perform a real visual identification using the attached image.

Analyze:

- leaf shape
- leaf arrangement
- leaf color
- venation
- stem characteristics
- flower or fruit if visible
- overall plant structure
- distinctive visual features
- visible signs of stress
- visible damage
- visible pests
- disease-like symptoms

Determine:

1. Most likely common plant name.
2. Scientific name only if adequately supported.
3. Visual identification confidence from 0 to 100.
4. Concise visual description.
5. Practical plant-specific care tips.
6. Whether significant visible health problems are present.

IMPORTANT:

Do not use a predefined or hardcoded answer.

If the photograph does not contain enough visual evidence
for reliable identification:

plantName = ""
scientificName = ""
confidence = 0

Do not diagnose a disease with certainty from an image alone.

Return ONLY the JSON object required by the response schema.
''',
    );

    try {
      return await _generateWithRetry(
        prompt: prompt,
        imagePart: imagePart,
      );
    } on IdentifyException {
      rethrow;
    } catch (
      error,
      stackTrace
    ) {
      _logError(
        'UNEXPECTED IDENTIFICATION ERROR',
        error,
        stackTrace,
      );

      throw const IdentifyException(
        IdentifyErrorType.unknown,
        'Unable to identify the plant. Please try again.',
      );
    }
  }

  // ============================================================
  // GENERATE WITH RETRY
  // ============================================================

  Future<IdentifyResult> _generateWithRetry({
    required TextPart prompt,
    required InlineDataPart imagePart,
  }) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (
      int attempt = 1;
      attempt <= _maxAttempts;
      attempt++
    ) {
      try {
        _log(
          'AI REQUEST ATTEMPT '
          '$attempt/$_maxAttempts',
        );

        final response =
            await _model.generateContent([
          Content.multi([
            prompt,
            imagePart,
          ]),
        ]);

        final String? text =
            response.text?.trim();

        if (text == null ||
            text.isEmpty) {
          throw const IdentifyException(
            IdentifyErrorType.emptyResponse,
            'Gemini returned an empty response.',
          );
        }

        final IdentifyResult result =
            _parseResult(text);

        _log(
          'AI IDENTIFICATION SUCCESS | '
          'Plant: ${result.plantName} | '
          'Scientific: ${result.scientificName} | '
          'Confidence: '
          '${result.confidence.toStringAsFixed(1)}',
        );

        return result;
      } on IdentifyException {
        rethrow;
      } on FirebaseAIException catch (
        error,
        stackTrace
      ) {
        lastError = error;
        lastStackTrace = stackTrace;

        _logError(
          'FIREBASE AI ERROR - ATTEMPT $attempt',
          error,
          stackTrace,
        );

        final IdentifyErrorType errorType =
            _classifyFirebaseError(
          error,
        );

        if (errorType ==
                IdentifyErrorType
                    .temporaryLimit &&
            attempt < _maxAttempts) {
          _log(
            'Temporary AI limit detected. '
            'Waiting '
            '${_retryDelay.inSeconds}s '
            'before retry...',
          );

          await Future<void>.delayed(
            _retryDelay,
          );

          continue;
        }

        throw IdentifyException(
          errorType,
          _userMessageFor(
            errorType,
          ),
        );
      } catch (
        error,
        stackTrace
      ) {
        lastError = error;
        lastStackTrace = stackTrace;

        _logError(
          'UNKNOWN AI ERROR - ATTEMPT $attempt',
          error,
          stackTrace,
        );

        throw const IdentifyException(
          IdentifyErrorType.unknown,
          'Unable to identify the plant. Please try again.',
        );
      }
    }

    _logError(
      'AI REQUEST FAILED AFTER ALL ATTEMPTS',
      lastError,
      lastStackTrace,
    );

    throw const IdentifyException(
      IdentifyErrorType.temporaryLimit,
      'GreenMind AI is temporarily unavailable. Please try again later.',
    );
  }

  // ============================================================
  // CLASSIFY FIREBASE ERROR
  // ============================================================

  IdentifyErrorType _classifyFirebaseError(
    FirebaseAIException error,
  ) {
    final String message =
        error.message.toLowerCase();

    final String raw =
        error.toString().toLowerCase();

    final String combined =
        '$message $raw';

    if (_containsAny(
      combined,
      [
        '429',
        'quota',
        'resource exhausted',
        'rate limit',
        'too many requests',
        'usage limit',
        'temporarily reached',
        'try again later',
      ],
    )) {
      return IdentifyErrorType
          .temporaryLimit;
    }

    if (_containsAny(
      combined,
      [
        'timeout',
        'timed out',
        'deadline exceeded',
      ],
    )) {
      return IdentifyErrorType.timeout;
    }

    if (_containsAny(
      combined,
      [
        'network',
        'connection',
        'socket',
        'failed host lookup',
        'internet',
        'connection reset',
        'connection refused',
      ],
    )) {
      return IdentifyErrorType.network;
    }

    if (_containsAny(
      combined,
      [
        'api not configured',
        'service disabled',
        'not configured',
        'invalid api key',
        'permission',
        'unauthorized',
      ],
    )) {
      return IdentifyErrorType.configuration;
    }

    if (_containsAny(
      combined,
      [
        'blocked',
        'safety',
        'prompt blocked',
        'content blocked',
      ],
    )) {
      return IdentifyErrorType.blocked;
    }

    if (_containsAny(
      combined,
      [
        'server error',
        'internal server error',
        '500',
        '502',
        '503',
        '504',
      ],
    )) {
      return IdentifyErrorType.server;
    }

    return IdentifyErrorType.unknown;
  }

  // ============================================================
  // USER FRIENDLY ERROR
  // ============================================================

  String _userMessageFor(
    IdentifyErrorType type,
  ) {
    switch (type) {
      case IdentifyErrorType.invalidImage:
        return 'The selected image is invalid. Please choose another image.';

      case IdentifyErrorType.unsupportedImage:
        return 'This image format is not supported. Please use JPEG, PNG, or WEBP.';

      case IdentifyErrorType.emptyResponse:
        return 'GreenMind AI returned an empty response. Please try again.';

      case IdentifyErrorType.temporaryLimit:
        return 'GreenMind AI is temporarily busy or has reached its usage limit. Please wait a little while and try again.';

      case IdentifyErrorType.network:
        return 'Unable to connect to GreenMind AI. Please check your internet connection and try again.';

      case IdentifyErrorType.timeout:
        return 'The AI request took too long. Please try again.';

      case IdentifyErrorType.configuration:
        return 'GreenMind AI is not properly configured. Please check the Firebase AI configuration.';

      case IdentifyErrorType.blocked:
        return 'The image or request could not be processed by the AI service. Please try another plant image.';

      case IdentifyErrorType.server:
        return 'GreenMind AI is temporarily unavailable. Please try again later.';

      case IdentifyErrorType.invalidResponse:
        return 'GreenMind AI returned an invalid result. Please try again.';

      case IdentifyErrorType.unknown:
        return 'Unable to identify the plant. Please try again.';
    }
  }

  // ============================================================
  // PARSE RESULT
  // ============================================================

  IdentifyResult _parseResult(
    String rawText,
  ) {
    final String cleaned =
        _cleanJson(rawText);

    dynamic decoded;

    try {
      decoded = jsonDecode(
        cleaned,
      );
    } catch (
      error,
      stackTrace
    ) {
      _logError(
        'JSON PARSE ERROR',
        error,
        stackTrace,
      );

      throw const IdentifyException(
        IdentifyErrorType.invalidResponse,
        'Gemini returned invalid JSON.',
      );
    }

    if (decoded is! Map) {
      throw const IdentifyException(
        IdentifyErrorType.invalidResponse,
        'Gemini response is not a JSON object.',
      );
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(
      decoded,
    );

    final String plantName =
        _stringValue(
      data['plantName'],
    );

    final String scientificName =
        _stringValue(
      data['scientificName'],
    );

    final double confidence =
        _doubleValue(
      data['confidence'],
    );

    final String description =
        _stringValue(
      data['description'],
    );

    final String careTips =
        _stringValue(
      data['careTips'],
    );

    final bool isHealthy =
        _boolValue(
      data['isHealthy'],
    );

    // ----------------------------------------------------------
    // INVALID CONFIDENCE
    // ----------------------------------------------------------

    if (!confidence.isFinite ||
        confidence < 0 ||
        confidence > 100) {
      throw const IdentifyException(
        IdentifyErrorType.invalidResponse,
        'Gemini returned an invalid confidence value.',
      );
    }

    // ----------------------------------------------------------
    // EMPTY IDENTIFICATION
    // ----------------------------------------------------------

    if (plantName.isEmpty) {
      return IdentifyResult(
        plantName: '',
        scientificName: '',
        confidence: 0,
        description: description,
        careTips: careTips,
        isHealthy: isHealthy,
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

  // ============================================================
  // CLEAN JSON
  // ============================================================

  String _cleanJson(
    String text,
  ) {
    var cleaned = text.trim();

    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(
        RegExp(
          r'^```(?:json)?\s*',
          caseSensitive: false,
        ),
        '',
      );

      cleaned = cleaned.replaceFirst(
        RegExp(
          r'\s*```$',
        ),
        '',
      );
    }

    return cleaned.trim();
  }

  // ============================================================
  // STRING VALUE
  // ============================================================

  String _stringValue(
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
  // DOUBLE VALUE
  // ============================================================

  double _doubleValue(
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
  // BOOLEAN VALUE
  // ============================================================

  bool _boolValue(
    dynamic value,
  ) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      final normalized =
          value.trim().toLowerCase();

      if (normalized == 'true') {
        return true;
      }

      if (normalized == 'false') {
        return false;
      }
    }

    return false;
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

    throw const IdentifyException(
      IdentifyErrorType.unsupportedImage,
      'Unsupported image format. Please use JPEG, PNG, or WEBP.',
    );
  }

  // ============================================================
  // STRING SEARCH
  // ============================================================

  bool _containsAny(
    String source,
    List<String> values,
  ) {
    for (final value in values) {
      if (source.contains(value)) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // DEBUG LOG
  // ============================================================

  void _log(
    String message,
  ) {
    _logger.d(
      '[GreenMind AI] $message',
    );
  }

  // ============================================================
  // DEBUG ERROR
  // ============================================================

  void _logError(
    String title,
    Object? error,
    StackTrace? stackTrace,
  ) {
    _logger.e(
      '[GreenMind AI] $title',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

// ================================================================
// ERROR TYPES
// ================================================================

enum IdentifyErrorType {
  invalidImage,
  unsupportedImage,
  emptyResponse,
  temporaryLimit,
  network,
  timeout,
  configuration,
  blocked,
  server,
  invalidResponse,
  unknown,
}

// ================================================================
// IDENTIFICATION EXCEPTION
// ================================================================

class IdentifyException
    implements Exception {
  final IdentifyErrorType type;
  final String message;

  const IdentifyException(
    this.type,
    this.message,
  );

  @override
  String toString() {
    return 'IdentifyException: $message';
  }
}