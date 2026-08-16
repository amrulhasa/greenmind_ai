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

class IdentifyNotifier extends Notifier<IdentifyState> {
  final ImagePicker _picker = ImagePicker();

  final IdentifyService _identifyService = IdentifyService();

  @override
  IdentifyState build() {
    return const IdentifyState();
  }

  // ============================================================
  // PICK FROM GALLERY
  // ============================================================

  Future<void> pickFromGallery() async {
    if (state.isLoading) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      // User cancelled.
      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        state = state.copyWith(
          errorMessage: 'The selected image is empty.',
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
      debugPrint('GALLERY IMAGE ERROR: $e');
      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage: 'Unable to select image.',
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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      // User cancelled.
      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        state = state.copyWith(
          errorMessage: 'The captured image is empty.',
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
      debugPrint('CAMERA IMAGE ERROR: $e');
      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage: 'Unable to take photo.',
      );
    }
  }

  // ============================================================
  // CLEAR IMAGE
  // ============================================================

  void clearImage() {
    state = const IdentifyState();
  }

  // ============================================================
  // IDENTIFY PLANT
  // ============================================================

  Future<void> identifyPlant() async {
    final imageBytes = state.imageBytes;

    // Prevent duplicate requests.
    if (state.isLoading) {
      return;
    }

    // No image selected.
    if (imageBytes == null || imageBytes.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please select or take a plant photo first.',
        clearError: false,
      );

      return;
    }

    // ==========================================================
    // START AI REQUEST
    // ==========================================================

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      // ========================================================
      // CALL AI SERVICE
      // ========================================================

      final IdentifyResult result =
          await _identifyService.identifyPlant(
        imageBytes,
      );

      debugPrint('================================');
      debugPrint('IDENTIFICATION RESULT');
      debugPrint('Plant: ${result.plantName}');
      debugPrint('Scientific: ${result.scientificName}');
      debugPrint('Confidence: ${result.confidence}');
      debugPrint('Healthy: ${result.isHealthy}');
      debugPrint('================================');

      // ========================================================
      // SHOW RESULT IMMEDIATELY
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
            .read(recentPlantsProvider.notifier)
            .addPlant(
              result: result,
              imageBytes: imageBytes,
            );

        debugPrint('Recent plant saved successfully.');
      } catch (saveError, saveStackTrace) {
        // AI result remains visible even if local storage fails.
        debugPrint(
          'RECENT PLANT SAVE ERROR: $saveError',
        );

        debugPrint(
          '$saveStackTrace',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('================================');
      debugPrint('IDENTIFY PLANT ERROR');
      debugPrint('ERROR: $error');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage: 'AI Error: $error',
      );
    }
  }
}

// ============================================================
// IDENTIFY STATE
// ============================================================

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

  IdentifyState copyWith({
    Uint8List? imageBytes,
    bool? isLoading,
    IdentifyResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return IdentifyState(
      imageBytes: imageBytes ?? this.imageBytes,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult
          ? null
          : result ?? this.result,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}