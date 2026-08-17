import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/providers/recent_plants_provider.dart';

import '../models/disease_result.dart';
import '../services/disease_service.dart';

final diseaseProvider =
    NotifierProvider<
        DiseaseNotifier,
        DiseaseState>(
  DiseaseNotifier.new,
);

class DiseaseNotifier
    extends Notifier<DiseaseState> {
  final ImagePicker _picker =
      ImagePicker();

  final DiseaseService _diseaseService =
      DiseaseService();

  @override
  DiseaseState build() {
    return const DiseaseState();
  }

  // ============================================================
  // PICK FROM GALLERY
  // ============================================================

  Future<void> pickFromGallery() async {
    if (state.isLoading) {
      return;
    }

    try {
      final XFile? image =
          await _picker.pickImage(
        source:
            ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) {
        return;
      }

      final bytes =
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
    } catch (e, stackTrace) {
      debugPrint(
        'GALLERY IMAGE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage:
            'Unable to select image.',
      );
    }
  }

  // ============================================================
  // PICK FROM CAMERA
  // ============================================================

  Future<void> pickFromCamera() async {
    if (state.isLoading) {
      return;
    }

    try {
      final XFile? image =
          await _picker.pickImage(
        source:
            ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) {
        return;
      }

      final bytes =
          await image.readAsBytes();

      if (bytes.isEmpty) {
        state = state.copyWith(
          errorMessage:
              'The captured image is empty.',
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
    } catch (e, stackTrace) {
      debugPrint(
        'CAMERA IMAGE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage:
            'Unable to take photo.',
      );
    }
  }

  // ============================================================
  // CLEAR IMAGE
  // ============================================================

  void clearImage() {
    state = const DiseaseState();
  }

  // ============================================================
  // DETECT DISEASE
  // ============================================================

  Future<void> detectDisease() async {
    final imageBytes =
        state.imageBytes;

    if (state.isLoading) {
      return;
    }

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

    try {
      // ========================================================
      // AI REQUEST
      // ========================================================

      final DiseaseResult result =
          await _diseaseService.detectDisease(
        imageBytes,
      );

      debugPrint(
        '================================',
      );

      debugPrint(
        'DISEASE DETECTION RESULT',
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
        '================================',
      );

      // ========================================================
      // SHOW RESULT FIRST
      // ========================================================

      state = state.copyWith(
        isLoading: false,
        result: result,
        clearResult: false,
        clearError: true,
      );

      // ========================================================
      // SAVE TO RECENT PLANTS
      // ========================================================

      try {
        await ref
            .read(
              recentPlantsProvider
                  .notifier,
            )
            .addDiseaseResult(
              result: result,
              imageBytes: imageBytes,
            );

        debugPrint(
          'Disease result saved to Recent Plants.',
        );
      } catch (saveError, saveStackTrace) {
        debugPrint(
          'RECENT DISEASE SAVE ERROR: $saveError',
        );

        debugPrint(
          '$saveStackTrace',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        '================================',
      );

      debugPrint(
        'DISEASE DETECTION ERROR',
      );

      debugPrint(
        'ERROR: $error',
      );

      debugPrint(
        'STACK TRACE:',
      );

      debugPrint(
        '$stackTrace',
      );

      debugPrint(
        '================================',
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

// ============================================================
// DISEASE STATE
// ============================================================

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