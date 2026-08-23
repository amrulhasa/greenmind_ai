import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/providers/recent_plants_provider.dart';
import '../models/disease_result.dart';
import '../services/disease_service.dart';

// ================================================================
// DISEASE PROVIDER
// ================================================================

final diseaseProvider =
    NotifierProvider<DiseaseNotifier, DiseaseState>(
  DiseaseNotifier.new,
);

// ================================================================
// DISEASE NOTIFIER
// ================================================================

class DiseaseNotifier extends Notifier<DiseaseState> {
  final ImagePicker _picker = ImagePicker();

  final DiseaseService _diseaseService =
      DiseaseService();

  @override
  DiseaseState build() {
    return const DiseaseState();
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
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes =
          await image.readAsBytes();

      if (bytes.isEmpty) {
        state = state.copyWith(
          errorMessage:
              'The selected image is empty.',
          clearResult: true,
        );

        return;
      }

      state = state.copyWith(
        imageBytes: bytes,
        isLoading: false,
        clearResult: true,
        clearError: true,
      );

      debugPrint(
        '[GreenMind AI] Disease image selected.',
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
    state = const DiseaseState();
  }

  // ==============================================================
  // DETECT DISEASE
  // ==============================================================

  Future<void> detectDisease() async {
    if (state.isLoading) {
      debugPrint(
        '[GreenMind AI] Duplicate disease request ignored.',
      );

      return;
    }

    final Uint8List? imageBytes =
        state.imageBytes;

    if (imageBytes == null ||
        imageBytes.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Please select or take a clear plant leaf photo first.',
      );

      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );

    debugPrint('');
    debugPrint(
      '========================================',
    );

    debugPrint(
      'GREENMIND AI - DISEASE DETECTION STARTED',
    );

    debugPrint(
      'IMAGE SIZE: ${imageBytes.length} bytes',
    );

    debugPrint(
      '========================================',
    );

    try {
      // ==========================================================
      // AI REQUEST
      // ==========================================================

      final DiseaseResult result =
          await _diseaseService.detectDisease(
        imageBytes,
      );

      debugPrint(
        '========================================',
      );

      debugPrint(
        'GREENMIND AI - DISEASE RESULT',
      );

      debugPrint(
        'Disease: ${result.diseaseName}',
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

      // ==========================================================
      // SHOW RESULT
      // ==========================================================

      state = state.copyWith(
        isLoading: false,
        result: result,
        clearError: true,
      );

      // ==========================================================
      // SAVE TO RECENT PLANTS + ADMIN FIRESTORE
      // ==========================================================

      debugPrint(
        '[GreenMind AI] Preparing to save disease result...',
      );

      try {
        final recentPlantsNotifier =
            ref.read(
          recentPlantsProvider.notifier,
        );

        // --------------------------------------------------------
        // WAIT FOR RECENT PLANTS INITIAL LOAD
        // --------------------------------------------------------

        await recentPlantsNotifier.ensureLoaded();

        debugPrint(
          '[GreenMind AI] Recent plants are ready.',
        );

        // --------------------------------------------------------
        // SAVE DISEASE TO ADMIN IDENTIFICATIONS
        //
        // IMPORTANT:
        // Admin screen reads the "identifications"
        // collection.
        // --------------------------------------------------------

        await recentPlantsNotifier
            .saveDiseaseToFirestore(
          result: result,
        );

        debugPrint(
          '[GreenMind AI] '
          'Disease result saved to Firestore identifications.',
        );

        // --------------------------------------------------------
        // SAVE TO USER RECENT PLANTS
        // --------------------------------------------------------

        await recentPlantsNotifier.addDiseaseResult(
          result: result,
          imageBytes: imageBytes,
        );

        debugPrint(
          '[GreenMind AI] '
          'Disease result saved to Recent Plants.',
        );

        debugPrint(
          '[GreenMind AI] '
          'Current recent count: '
          '${recentPlantsNotifier.state.plants.length}',
        );
      } catch (saveError, saveStackTrace) {
        debugPrint(
          '========================================',
        );

        debugPrint(
          '[GreenMind AI] DISEASE SAVE ERROR',
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

        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Disease detected, but it could not be saved.',
        );

        return;
      }

      // ==========================================================
      // FINAL STATE
      // ==========================================================

      state = state.copyWith(
        isLoading: false,
        result: result,
        clearError: true,
      );

      debugPrint(
        '[GreenMind AI] '
        'Disease detection flow completed successfully.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'GREENMIND AI - DISEASE DETECTION ERROR',
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
            'Unable to analyze the plant. Please try again.',
      );
    }
  }
}

// ================================================================
// DISEASE STATE
// ================================================================

class DiseaseState {
  final Uint8List? imageBytes;
  final bool isLoading;
  final DiseaseResult? result;
  final String? errorMessage;

  const DiseaseState({
    this.imageBytes,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  DiseaseState copyWith({
    Uint8List? imageBytes,
    bool? isLoading,
    DiseaseResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return DiseaseState(
      imageBytes:
          imageBytes ?? this.imageBytes,
      isLoading:
          isLoading ?? this.isLoading,
      result:
          clearResult
              ? null
              : result ?? this.result,
      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,
    );
  }
}