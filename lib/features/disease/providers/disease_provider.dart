import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/disease_result.dart';

final diseaseProvider =
    NotifierProvider<DiseaseNotifier, DiseaseState>(
  DiseaseNotifier.new,
);

class DiseaseNotifier extends Notifier<DiseaseState> {
  final ImagePicker _picker = ImagePicker();

  @override
  DiseaseState build() {
    return const DiseaseState();
  }

  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    state = state.copyWith(
      image: File(image.path),
    );
  }

  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return;

    state = state.copyWith(
      image: File(image.path),
    );
  }

  void clearImage() {
    state = const DiseaseState();
  }

  Future<void> detectDisease() async {
    if (state.image == null) return;

    state = state.copyWith(
      isLoading: true,
    );

    await Future.delayed(
      const Duration(seconds: 2),
    );

    state = state.copyWith(
      isLoading: false,
      result: const DiseaseResult(
        diseaseName: 'Healthy Leaf',
        confidence: 98.7,
        description:
            'The uploaded plant leaf appears healthy with no visible disease symptoms.',
        treatment:
            'No treatment is required. Continue regular watering and fertilization.',
        prevention:
            'Maintain proper sunlight, watering schedule, and good air circulation.',
        isHealthy: true,
      ),
    );
  }
}

class DiseaseState {
  final File? image;
  final bool isLoading;
  final DiseaseResult? result;

  const DiseaseState({
    this.image,
    this.isLoading = false,
    this.result,
  });

  DiseaseState copyWith({
    File? image,
    bool? isLoading,
    DiseaseResult? result,
  }) {
    return DiseaseState(
      image: image ?? this.image,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
    );
  }
}