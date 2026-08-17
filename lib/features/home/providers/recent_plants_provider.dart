
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../disease/models/disease_result.dart';
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

  FirebaseAuth get _auth {
    return FirebaseAuth.instance;
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
    final user =
        _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );

      return;
    }

    try {
      final plants =
          await _storageService
              .loadRecentPlants(
        userId: user.uid,
      );

      state = state.copyWith(
        plants: plants,
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'RECENT PLANTS LOAD ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load recent plants.',
      );
    }
  }

  // ============================================================
  // PUBLIC RELOAD
  // ============================================================

  Future<void> reloadPlants() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    await _loadPlants();
  }

  // ============================================================
  // ADD PLANT IDENTIFICATION
  // ============================================================

  Future<void> addPlant({
    required IdentifyResult result,
    required Uint8List imageBytes,
  }) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    try {
      if (imageBytes.isEmpty) {
        throw Exception(
          'Image data is empty.',
        );
      }

      final imageBase64 =
          await _storageService
              .imageToBase64(
        imageBytes,
      );

      final newPlant =
          RecentPlant(
        scanType:
            RecentPlant.identification,

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

      await _insertRecentPlant(
        newPlant,
        user.uid,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'RECENT PLANT SAVE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to save recent plant.',
      );
    }
  }

  // ============================================================
  // ADD DISEASE DETECTION
  // ============================================================

  Future<void> addDiseaseResult({
    required DiseaseResult result,
    required Uint8List imageBytes,
  }) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    try {
      if (imageBytes.isEmpty) {
        throw Exception(
          'Image data is empty.',
        );
      }

      final imageBase64 =
          await _storageService
              .imageToBase64(
        imageBytes,
      );

      final newPlant =
          RecentPlant(
        scanType:
            RecentPlant.diseaseDetection,

        plantName:
            'Plant Health Scan',

        scientificName:
            '',

        diseaseName:
            result.diseaseName,

        symptoms:
            result.symptoms,

        treatment:
            result.treatment,

        prevention:
            result.prevention,

        confidence:
            result.confidence,

        description:
            result.description,

        careTips:
            _buildDiseaseCareTips(
          result,
        ),

        isHealthy:
            result.isHealthy,

        identifiedAt:
            DateTime.now(),

        imageBase64:
            imageBase64,
      );

      await _insertRecentPlant(
        newPlant,
        user.uid,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'RECENT DISEASE SAVE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to save recent disease result.',
      );
    }
  }

  // ============================================================
  // INSERT
  // ============================================================

  Future<void> _insertRecentPlant(
    RecentPlant newPlant,
    String userId,
  ) async {
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
      userId: userId,
      plants: limitedPlants,
    );

    state = state.copyWith(
      plants: limitedPlants,
      isLoading: false,
      clearError: true,
    );
  }

  // ============================================================
  // DISEASE CARE SUMMARY
  // ============================================================

  String _buildDiseaseCareTips(
    DiseaseResult result,
  ) {
    final parts =
        <String>[];

    if (result.treatment
        .trim()
        .isNotEmpty) {
      parts.add(
        'Treatment: '
        '${result.treatment.trim()}',
      );
    }

    if (result.prevention
        .trim()
        .isNotEmpty) {
      parts.add(
        'Prevention: '
        '${result.prevention.trim()}',
      );
    }

    return parts.isEmpty
        ? 'No additional care information available.'
        : parts.join('\n\n');
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> clearAll() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );

      return;
    }

    try {
      await _storageService
          .clearRecentPlants(
        userId: user.uid,
      );

      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'RECENT PLANTS CLEAR ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
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