import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final identifyProvider =
    NotifierProvider<IdentifyNotifier, IdentifyState>(
  IdentifyNotifier.new,
);

class IdentifyNotifier extends Notifier<IdentifyState> {
  final ImagePicker _picker = ImagePicker();

  @override
  IdentifyState build() {
    return const IdentifyState();
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
    state = const IdentifyState();
  }

  Future<void> identifyPlant() async {
    if (state.image == null) return;

    state = state.copyWith(
      isLoading: true,
    );

    await Future.delayed(
      const Duration(seconds: 2),
    );

    state = state.copyWith(
      isLoading: false,
    );
  }
}

class IdentifyState {
  final File? image;
  final bool isLoading;

  const IdentifyState({
    this.image,
    this.isLoading = false,
  });

  IdentifyState copyWith({
    File? image,
    bool? isLoading,
  }) {
    return IdentifyState(
      image: image ?? this.image,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}