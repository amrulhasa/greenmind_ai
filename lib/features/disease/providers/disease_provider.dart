import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/disease_result.dart';
import '../services/disease_service.dart';

final diseaseProvider =
    NotifierProvider<DiseaseNotifier, DiseaseState>(
  DiseaseNotifier.new,
);

class DiseaseNotifier extends Notifier<DiseaseState> {
  final ImagePicker _picker = ImagePicker();
  final DiseaseService _diseaseService = DiseaseService();

  @override
  DiseaseState build() {
    return const DiseaseState();
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
    state = const DiseaseState();
  }

  // ==============================
  // DETECT DISEASE
  // ==============================

  Future<void> detectDisease() async {
    final imageBytes = state.imageBytes;

    if (imageBytes == null) return;

    state = state.copyWith(
      isLoading: true,
      clearResult: true,
      clearError: true,
    );

    try {
      final DiseaseResult result =
          await _diseaseService.detectDisease(
        imageBytes,
      );

      state = state.copyWith(
        isLoading: false,
        result: result,
        clearResult: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage:
            'Unable to analyze the plant. Please try again.',
        clearError: false,
      );
    }
  }
}

// ==========================================
// DISEASE STATE
// ==========================================

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