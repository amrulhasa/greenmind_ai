import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../identify/models/identify_result.dart';
import '../models/recent_plant.dart';
import '../services/recent_plants_storage_service.dart';

final recentPlantsStorageServiceProvider =
    Provider<RecentPlantsStorageService>(
  (ref) {
    return RecentPlantsStorageService();
  },
);

final recentPlantsProvider =
    NotifierProvider<
        RecentPlantsNotifier,
        RecentPlantsState>(
  RecentPlantsNotifier.new,
);

class RecentPlantsNotifier
    extends Notifier<RecentPlantsState> {
  RecentPlantsStorageService
      get _storageService {
    return ref.read(
      recentPlantsStorageServiceProvider,
    );
  }

  @override
  RecentPlantsState build() {
    Future.microtask(
      _loadPlants,
    );

    return const RecentPlantsState(
      isLoading: true,
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadPlants() async {
    try {
      final plants =
          await _storageService
              .loadRecentPlants();

      state = state.copyWith(
        plants: plants,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load recent plants.',
      );
    }
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> addPlant({
    required IdentifyResult result,
    required Uint8List imageBytes,
  }) async {
    try {
      final imageBase64 =
          await _storageService
              .imageToBase64(
        imageBytes,
      );

      final newPlant = RecentPlant(
        plantName:
            result.plantName.isEmpty
                ? 'Unknown Plant'
                : result.plantName,
        scientificName:
            result.scientificName,
        confidence:
            result.confidence,
        description:
            result.description,
        careTips:
            result.careTips,
        isHealthy:
            result.isHealthy,
        identifiedAt:
            DateTime.now(),
        imageBase64:
            imageBase64,
      );

      final updatedPlants = [
        newPlant,
        ...state.plants,
      ];

      final limitedPlants =
          updatedPlants
              .take(5)
              .toList();

      await _storageService
          .saveRecentPlants(
        limitedPlants,
      );

      state = state.copyWith(
        plants: limitedPlants,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Unable to save recent plant.',
      );
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> clearAll() async {
    try {
      await _storageService
          .clearRecentPlants();

      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Unable to clear recent plants.',
      );
    }
  }
}

// ============================================================
// STATE
// ============================================================

class RecentPlantsState {
  final List<RecentPlant> plants;
  final bool isLoading;
  final String? errorMessage;

  const RecentPlantsState({
    this.plants = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RecentPlantsState copyWith({
    List<RecentPlant>? plants,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RecentPlantsState(
      plants:
          plants ?? this.plants,
      isLoading:
          isLoading ?? this.isLoading,
      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,
    );
  }
}