import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../disease/models/disease_result.dart';
import '../../identify/models/identify_result.dart';

import '../models/recent_plant.dart';
import '../services/recent_plants_storage_service.dart';

// ================================================================
// STORAGE SERVICE PROVIDER
// ================================================================

final recentPlantsStorageServiceProvider =
    Provider<RecentPlantsStorageService>(
  (ref) {
    return RecentPlantsStorageService();
  },
);

// ================================================================
// RECENT PLANTS PROVIDER
// ================================================================

final recentPlantsProvider =
    NotifierProvider<
        RecentPlantsNotifier,
        RecentPlantsState>(
  RecentPlantsNotifier.new,
);

// ================================================================
// NOTIFIER
// ================================================================

class RecentPlantsNotifier
    extends Notifier<RecentPlantsState> {
  Future<void>? _loadOperation;

  // ==============================================================
  // STORAGE
  // ==============================================================

  RecentPlantsStorageService get _storageService {
    return ref.read(
      recentPlantsStorageServiceProvider,
    );
  }

  // ==============================================================
  // AUTH
  // ==============================================================

  FirebaseAuth get _auth {
    return FirebaseAuth.instance;
  }

  // ==============================================================
  // FIRESTORE
  // ==============================================================

  FirebaseFirestore get _firestore {
    return FirebaseFirestore.instance;
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  RecentPlantsState build() {
    final operation = _loadPlants();

    _loadOperation = operation;

    return const RecentPlantsState(
      isLoading: true,
    );
  }

  // ==============================================================
  // ENSURE LOADED
  // ==============================================================

  Future<void> ensureLoaded() async {
    if (!state.isLoading) {
      return;
    }

    final operation = _loadOperation;

    if (operation != null) {
      try {
        await operation;
      } catch (_) {
        // _loadPlants handles its own state error.
      }

      return;
    }

    await _loadPlants();
  }

  // ==============================================================
  // LOAD PLANTS
  // ==============================================================

  Future<void> _loadPlants() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );

      return;
    }

    try {
      debugPrint(
        '[GreenMind AI] Loading recent plants...',
      );

      debugPrint(
        '[GreenMind AI] USER ID: ${user.uid}',
      );

      final plants =
          await _storageService.loadRecentPlants(
        userId: user.uid,
      );

      state = state.copyWith(
        plants: plants,
        isLoading: false,
        clearError: true,
      );

      debugPrint(
        '[GreenMind AI] '
        'Recent plants loaded: ${plants.length}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] RECENT PLANTS LOAD ERROR',
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
        errorMessage:
            'Unable to load recent plants.',
      );
    }
  }

  // ==============================================================
  // RELOAD
  // ==============================================================

  Future<void> reloadPlants() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );

      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    await _loadPlants();
  }

  // ==============================================================
  // ADD PLANT IDENTIFICATION
  // ==============================================================

  Future<void> addPlant({
    required IdentifyResult result,
    required Uint8List imageBytes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    if (imageBytes.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Image data is empty.',
      );

      return;
    }

    try {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] SAVING IDENTIFICATION',
      );

      debugPrint(
        'USER ID: ${user.uid}',
      );

      debugPrint(
        'PLANT: ${result.plantName}',
      );

      debugPrint(
        'CONFIDENCE: ${result.confidence}',
      );

      // ----------------------------------------------------------
      // ADMIN FIRESTORE RECORD
      // ----------------------------------------------------------

      await _saveIdentificationToFirestore(
        userId: user.uid,
        result: result,
      );

      // ----------------------------------------------------------
      // IMAGE → BASE64
      // ----------------------------------------------------------

      final imageBase64 =
          await _storageService.imageToBase64(
        imageBytes,
      );

      // ----------------------------------------------------------
      // CREATE RECENT PLANT
      // ----------------------------------------------------------

      final newPlant = RecentPlant(
        scanType:
            RecentPlant.identification,

        plantName:
            result.plantName.trim().isEmpty
                ? 'Unknown Plant'
                : result.plantName.trim(),

        scientificName:
            result.scientificName.trim(),

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

      // ----------------------------------------------------------
      // INSERT
      // ----------------------------------------------------------

      await _insertRecentPlant(
        newPlant,
        user.uid,
      );

      debugPrint(
        '[GreenMind AI] '
        'Identification saved successfully.',
      );

      debugPrint(
        '========================================',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] PLANT SAVE ERROR',
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
        errorMessage:
            'Unable to save plant identification.',
      );
    }
  }

  // ==============================================================
  // SAVE IDENTIFICATION TO FIRESTORE
  // ==============================================================

  Future<void> _saveIdentificationToFirestore({
    required String userId,
    required IdentifyResult result,
  }) async {
    final reference =
        _firestore
            .collection('identifications')
            .doc();

    final plantName =
        result.plantName.trim();

    final scientificName =
        result.scientificName.trim();

    final status =
        result.isHealthy
            ? 'healthy'
            : 'unhealthy';

    await reference.set({
      'userId': userId,

      'plantName':
          plantName.isEmpty
              ? 'Unknown Plant'
              : plantName,

      'scientificName':
          scientificName,

      'confidence':
          result.confidence,

      'description':
          result.description,

      'careTips':
          result.careTips,

      'isHealthy':
          result.isHealthy,

      'status':
          status,

      'scanType':
          'identification',

      'createdAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    debugPrint(
      '[GreenMind AI] '
      'Identification document ID: ${reference.id}',
    );
  }

  // ==============================================================
  // SAVE DISEASE RESULT TO FIRESTORE
  // ==============================================================
  //
  // IMPORTANT:
  // Admin Plant Management screen reads:
  //
  // identifications
  //
  // Therefore disease detection must also create a document
  // inside this collection.
  //
  // ==============================================================

  Future<void> saveDiseaseToFirestore({
    required DiseaseResult result,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    try {
      final reference =
          _firestore
              .collection('identifications')
              .doc();

      final diseaseName =
          result.diseaseName.trim();

      final status =
          result.isHealthy
              ? 'healthy'
              : 'unhealthy';

      await reference.set({
        // --------------------------------------------------------
        // OWNER
        // --------------------------------------------------------

        'userId':
            user.uid,

        // --------------------------------------------------------
        // PLANT
        //
        // Disease detection does not necessarily return
        // plant species name.
        // So we keep a clear label.
        // --------------------------------------------------------

        'plantName':
            diseaseName.isEmpty
                ? 'Unknown Disease'
                : diseaseName,

        'scientificName':
            '',

        // --------------------------------------------------------
        // DISEASE INFORMATION
        // --------------------------------------------------------

        'diseaseName':
            diseaseName.isEmpty
                ? 'Unknown Disease'
                : diseaseName,

        'symptoms':
            result.symptoms.trim(),

        'treatment':
            result.treatment.trim(),

        'prevention':
            result.prevention.trim(),

        // --------------------------------------------------------
        // AI RESULT
        // --------------------------------------------------------

        'confidence':
            result.confidence,

        'description':
            result.description.trim(),

        'careTips':
            _buildDiseaseCareTips(
          result,
        ),

        'isHealthy':
            result.isHealthy,

        'status':
            status,

        // --------------------------------------------------------
        // IMPORTANT TYPE
        // --------------------------------------------------------

        'scanType':
            'disease_detection',

        // --------------------------------------------------------
        // TIMESTAMP
        // --------------------------------------------------------

        'createdAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      debugPrint(
        '[GreenMind AI] '
        'Disease Firestore document created: '
        '${reference.id}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] '
        'DISEASE FIRESTORE SAVE ERROR',
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

      rethrow;
    }
  }

  // ==============================================================
  // ADD DISEASE RESULT
  // ==============================================================

  Future<void> addDiseaseResult({
    required DiseaseResult result,
    required Uint8List imageBytes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      throw Exception(
        'No authenticated user found.',
      );
    }

    if (imageBytes.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Image data is empty.',
      );

      throw Exception(
        'Disease image is empty.',
      );
    }

    try {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] SAVING DISEASE RESULT',
      );

      debugPrint(
        'USER ID: ${user.uid}',
      );

      debugPrint(
        'DISEASE: ${result.diseaseName}',
      );

      debugPrint(
        'CONFIDENCE: ${result.confidence}',
      );

      debugPrint(
        'HEALTHY: ${result.isHealthy}',
      );

      debugPrint(
        'IMAGE SIZE: ${imageBytes.length} bytes',
      );

      // ----------------------------------------------------------
      // IMAGE → BASE64
      // ----------------------------------------------------------

      final imageBase64 =
          await _storageService.imageToBase64(
        imageBytes,
      );

      if (imageBase64.isEmpty) {
        throw Exception(
          'Generated image data is empty.',
        );
      }

      debugPrint(
        '[GreenMind AI] '
        'Disease image converted to Base64.',
      );

      debugPrint(
        '[GreenMind AI] '
        'Base64 length: ${imageBase64.length}',
      );

      // ----------------------------------------------------------
      // CREATE RECENT PLANT
      // ----------------------------------------------------------

      final newPlant = RecentPlant(
        scanType:
            RecentPlant.diseaseDetection,

        plantName:
            'Plant Health Scan',

        scientificName:
            '',

        diseaseName:
            result.diseaseName.trim(),

        symptoms:
            result.symptoms.trim(),

        treatment:
            result.treatment.trim(),

        prevention:
            result.prevention.trim(),

        confidence:
            result.confidence,

        description:
            result.description.trim(),

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

      // ----------------------------------------------------------
      // SAVE TO RECENT PLANTS
      // ----------------------------------------------------------

      await _insertRecentPlant(
        newPlant,
        user.uid,
      );

      debugPrint(
        '[GreenMind AI] '
        'Disease result saved successfully.',
      );

      debugPrint(
        '========================================',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] RECENT DISEASE SAVE ERROR',
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
        errorMessage:
            'Unable to save recent disease result.',
      );

      rethrow;
    }
  }

  // ==============================================================
  // INSERT RECENT PLANT
  // ==============================================================

  Future<void> _insertRecentPlant(
    RecentPlant newPlant,
    String userId,
  ) async {
    final currentPlants =
        [...state.plants];

    final filteredPlants =
        currentPlants.where(
      (plant) {
        if (!newPlant.hasImage) {
          return true;
        }

        if (!plant.hasImage) {
          return true;
        }

        final sameImage =
            plant.imageBase64 ==
                newPlant.imageBase64;

        if (sameImage) {
          debugPrint(
            '[GreenMind AI] '
            'Duplicate image detected. '
            'Replacing old recent scan.',
          );

          return false;
        }

        return true;
      },
    ).toList();

    final updatedPlants = [
      newPlant,
      ...filteredPlants,
    ];

    final limitedPlants =
        updatedPlants
            .take(5)
            .toList();

    debugPrint(
      '[GreenMind AI] '
      'Saving ${limitedPlants.length} recent plants...',
    );

    await _storageService.saveRecentPlants(
      userId: userId,
      plants: limitedPlants,
    );

    state = state.copyWith(
      plants: limitedPlants,
      isLoading: false,
      clearError: true,
    );

    debugPrint(
      '[GreenMind AI] '
      'Recent Plants state updated: '
      '${limitedPlants.length}',
    );
  }

  // ==============================================================
  // DISEASE CARE TIPS
  // ==============================================================

  String _buildDiseaseCareTips(
    DiseaseResult result,
  ) {
    final parts = <String>[];

    final treatment =
        result.treatment.trim();

    final prevention =
        result.prevention.trim();

    if (treatment.isNotEmpty) {
      parts.add(
        'Treatment: $treatment',
      );
    }

    if (prevention.isNotEmpty) {
      parts.add(
        'Prevention: $prevention',
      );
    }

    if (parts.isEmpty) {
      return 'No additional care information available.';
    }

    return parts.join(
      '\n\n',
    );
  }

  // ==============================================================
  // CLEAR ALL
  // ==============================================================

  Future<void> clearAll() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );

      return;
    }

    try {
      debugPrint(
        '[GreenMind AI] '
        'Clearing all recent plants...',
      );

      await _storageService.clearRecentPlants(
        userId: user.uid,
      );

      state = state.copyWith(
        plants: const [],
        isLoading: false,
        clearError: true,
      );

      debugPrint(
        '[GreenMind AI] '
        'All recent plants cleared.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        '[GreenMind AI] RECENT PLANTS CLEAR ERROR',
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
        errorMessage:
            'Unable to clear recent plants.',
      );
    }
  }
}

// ================================================================
// STATE
// ================================================================

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