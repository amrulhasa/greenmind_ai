import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

  // ==============================
  // PICK IMAGE FROM GALLERY
  // ==============================

  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    state = state.copyWith(
      imageBytes: bytes,
      clearResult: true,
      clearError: true,
    );
  }

  // ==============================
  // PICK IMAGE FROM CAMERA
  // ==============================

  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    state = state.copyWith(
      imageBytes: bytes,
      clearResult: true,
      clearError: true,
    );
  }

  // ==============================
  // CLEAR IMAGE
  // ==============================

  void clearImage() {
    state = const IdentifyState();
  }

  // ==============================
  // IDENTIFY PLANT
  // ==============================

  Future<void> identifyPlant() async {
    final imageBytes = state.imageBytes;

    if (imageBytes == null) return;

    // Start loading
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final IdentifyResult result =
          await _identifyService.identifyPlant(
        imageBytes,
      );

      // ==========================================
      // DEBUG: RESULT RECEIVED BY PROVIDER
      // ==========================================

      debugPrint('================================');
      debugPrint('RESULT RECEIVED BY PROVIDER');
      debugPrint('Plant Name: ${result.plantName}');
      debugPrint('Scientific Name: ${result.scientificName}');
      debugPrint('Confidence: ${result.confidence}');
      debugPrint('Description: ${result.description}');
      debugPrint('Care Tips: ${result.careTips}');
      debugPrint('Healthy: ${result.isHealthy}');
      debugPrint('================================');

      // Update state with AI result
      state = state.copyWith(
        isLoading: false,
        result: result,
        clearResult: false,
        clearError: true,
      );

      // ==========================================
      // DEBUG: STATE UPDATED
      // ==========================================

      debugPrint('================================');
      debugPrint('STATE UPDATED');
      debugPrint('State Result: ${state.result}');
      debugPrint('Loading: ${state.isLoading}');
      debugPrint('Error: ${state.errorMessage}');
      debugPrint('================================');
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('IDENTIFY PLANT ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage: 'AI Error: $e',
        clearError: false,
      );
    }
  }
}

// ==========================================
// IDENTIFY STATE
// ==========================================

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
          : (result ?? this.result),

      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}