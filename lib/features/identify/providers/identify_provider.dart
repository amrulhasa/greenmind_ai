import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/providers/recent_plants_provider.dart';
import '../models/identify_result.dart';
import '../services/identify_service.dart';

final identifyProvider =
    NotifierProvider<IdentifyNotifier, IdentifyState>(
  IdentifyNotifier.new,
);

// ================================================================
// IDENTIFY NOTIFIER
// ================================================================

class IdentifyNotifier extends Notifier<IdentifyState> {
  final ImagePicker _picker = ImagePicker();

  final IdentifyService _identifyService =
      IdentifyService();

  @override
  IdentifyState build() {
    return const IdentifyState();
  }

  // ==============================================================
  // PICK FROM GALLERY
  // ==============================================================

  Future<void> pickFromGallery() async {
    await _pickImage(
      ImageSource.gallery,
    );
  }

  // ==============================================================
  // PICK FROM CAMERA
  // ==============================================================

  Future<void> pickFromCamera() async {
    await _pickImage(
      ImageSource.camera,
    );
  }

  // ==============================================================
  // COMMON IMAGE PICKER
  // ==============================================================

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    if (state.isLoading) {
      return;
    }

    try {
      final XFile? image =
          await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      // ----------------------------------------------------------
      // USER CANCELLED
      // ----------------------------------------------------------

      if (image == null) {
        return;
      }

      // ----------------------------------------------------------
      // READ IMAGE
      // ----------------------------------------------------------

      final Uint8List bytes =
          await image.readAsBytes();

      // ----------------------------------------------------------
      // EMPTY IMAGE
      // ----------------------------------------------------------

      if (bytes.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          clearResult: true,
          errorMessage:
              'The selected image is empty. Please choose another image.',
        );

        return;
      }

      // ----------------------------------------------------------
      // SAVE IMAGE IN STATE
      // ----------------------------------------------------------

      state = state.copyWith(
        imageBytes: bytes,
        isLoading: false,
        clearResult: true,
        clearError: true,
      );

      debugPrint(
        '[GreenMind AI] Image selected successfully.',
      );

      debugPrint(
        '[GreenMind AI] Image size: ${bytes.length} bytes',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] IMAGE PICK ERROR',
      );

      debugPrint(
        'ERROR: $error',
      );

      debugPrint(
        'STACK TRACE:\n$stackTrace',
      );

      debugPrint(
        '========================================',
      );

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage:
            source == ImageSource.camera
                ? 'Unable to take photo. Please try again.'
                : 'Unable to select image. Please try again.',
      );
    }
  }

  // ==============================================================
  // CLEAR IMAGE
  // ==============================================================

  void clearImage() {
    state = const IdentifyState();
  }

  // ==============================================================
  // IDENTIFY PLANT
  // ==============================================================

  Future<void> identifyPlant() async {
    // ------------------------------------------------------------
    // PREVENT DUPLICATE REQUEST
    // ------------------------------------------------------------

    if (state.isLoading) {
      debugPrint(
        '[GreenMind AI] Duplicate request ignored.',
      );

      return;
    }

    // ------------------------------------------------------------
    // GET IMAGE
    // ------------------------------------------------------------

    final Uint8List? imageBytes =
        state.imageBytes;

    // ------------------------------------------------------------
    // VALIDATE IMAGE
    // ------------------------------------------------------------

    if (imageBytes == null ||
        imageBytes.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Please select or take a plant photo first.',
      );

      return;
    }

    // ------------------------------------------------------------
    // START LOADING
    // ------------------------------------------------------------

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    debugPrint('');
    debugPrint(
      '========================================',
    );

    debugPrint(
      'GREENMIND AI - IDENTIFICATION STARTED',
    );

    debugPrint(
      'IMAGE SIZE: ${imageBytes.length} bytes',
    );

    debugPrint(
      '========================================',
    );

    try {
      // ----------------------------------------------------------
      // AI IDENTIFICATION
      // ----------------------------------------------------------

      final IdentifyResult result =
          await _identifyService.identifyPlant(
        imageBytes,
      );

      // ----------------------------------------------------------
      // LOG RESULT
      // ----------------------------------------------------------

      debugPrint(
        '========================================',
      );

      debugPrint(
        'GREENMIND AI - IDENTIFICATION RESULT',
      );

      debugPrint(
        'Plant: ${result.plantName}',
      );

      debugPrint(
        'Scientific: ${result.scientificName}',
      );

      debugPrint(
        'Confidence: ${result.confidence}',
      );

      debugPrint(
        'Healthy: ${result.isHealthy}',
      );

      debugPrint(
        '========================================',
      );

      // ----------------------------------------------------------
      // INVALID IDENTIFICATION
      // ----------------------------------------------------------

      if (!result.hasPlantName) {
        state = state.copyWith(
          isLoading: false,
          clearResult: true,
          errorMessage:
              'AI could not confidently identify the plant. '
              'Please try a clearer photo showing the leaves, '
              'stem, or flowers.',
        );

        return;
      }

      // ----------------------------------------------------------
      // SHOW RESULT IMMEDIATELY
      // ----------------------------------------------------------

      state = state.copyWith(
        isLoading: false,
        result: result,
        clearError: true,
      );

      // ----------------------------------------------------------
      // SAVE TO RECENT PLANTS
      //
      // IMPORTANT:
      // Firestore save is handled inside
      // RecentPlantsNotifier.
      //
      // This prevents duplicate Firestore documents.
      // ----------------------------------------------------------

      try {
        await ref
            .read(
              recentPlantsProvider.notifier,
            )
            .addPlant(
              result: result,
              imageBytes: imageBytes,
            );

        debugPrint(
          '[GreenMind AI] '
          'Identification saved successfully.',
        );
      } catch (
        saveError,
        saveStackTrace
      ) {
        debugPrint(
          '========================================',
        );

        debugPrint(
          '[GreenMind AI] '
          'RECENT PLANT SAVE ERROR',
        );

        debugPrint(
          'ERROR: $saveError',
        );

        debugPrint(
          'STACK TRACE:\n$saveStackTrace',
        );

        debugPrint(
          '========================================',
        );
      }
    } on IdentifyException catch (
      error,
      stackTrace
    ) {
      // ----------------------------------------------------------
      // KNOWN AI ERROR
      // ----------------------------------------------------------

      debugPrint(
        '========================================',
      );

      debugPrint(
        'GREENMIND AI - IDENTIFICATION ERROR',
      );

      debugPrint(
        'TYPE: ${error.type}',
      );

      debugPrint(
        'MESSAGE: ${error.message}',
      );

      debugPrint(
        'STACK TRACE:\n$stackTrace',
      );

      debugPrint(
        '========================================',
      );

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage:
            error.message,
      );
    } catch (
      error,
      stackTrace
    ) {
      // ----------------------------------------------------------
      // UNEXPECTED ERROR
      // ----------------------------------------------------------

      debugPrint(
        '========================================',
      );

      debugPrint(
        'GREENMIND AI - UNEXPECTED ERROR',
      );

      debugPrint(
        'ERROR: $error',
      );

      debugPrint(
        'STACK TRACE:\n$stackTrace',
      );

      debugPrint(
        '========================================',
      );

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage:
            'Unable to identify the plant. Please try again.',
      );
    }
  }
}

// ================================================================
// IDENTIFY STATE
// ================================================================

class IdentifyState {
  final Uint8List? imageBytes;
  final bool isLoading;
  final IdentifyResult? result;
  final String? errorMessage;

  const IdentifyState({
    this.imageBytes,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  // ==============================================================
  // COPY WITH
  // ==============================================================

  IdentifyState copyWith({
    Uint8List? imageBytes,
    bool? isLoading,
    IdentifyResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return IdentifyState(
      imageBytes: clearImage
          ? null
          : imageBytes ?? this.imageBytes,

      isLoading:
          isLoading ?? this.isLoading,

      result: clearResult
          ? null
          : result ?? this.result,

      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  bool get hasImage {
    return imageBytes != null &&
        imageBytes!.isNotEmpty;
  }

  bool get hasResult {
    return result != null;
  }

  bool get hasError {
    return errorMessage != null &&
        errorMessage!.trim().isNotEmpty;
  }
}