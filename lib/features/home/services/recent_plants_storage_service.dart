import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

import '../models/recent_plant.dart';

class RecentPlantsStorageService {
  RecentPlantsStorageService();

  final Logger _logger = Logger();

  // ============================================================
  // FIREBASE
  // ============================================================

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CONSTANTS
  // ============================================================

  static const int _maxRecentPlants = 5;

  static const int _imageMaxWidth = 500;

  static const int _imageQuality = 50;

  // ============================================================
  // COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      _recentPlantsCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recentPlants');
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser {
    return _auth.currentUser;
  }

  // ============================================================
  // VALIDATE USER
  // ============================================================

  void _validateUser(
    String userId,
  ) {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    if (user.uid != userId) {
      throw Exception(
        'Unauthorized recent plants operation.',
      );
    }
  }

  // ============================================================
  // LOAD RECENT PLANTS
  // ============================================================

  Future<List<RecentPlant>> loadRecentPlants({
    required String userId,
  }) async {
    _validateUser(userId);

    try {
      final collection =
          _recentPlantsCollection(userId);

      QuerySnapshot<Map<String, dynamic>>
          snapshot;

      try {
        snapshot = await collection
            .orderBy(
              'identifiedAt',
              descending: true,
            )
            .limit(_maxRecentPlants)
            .get();
      } on FirebaseException catch (error) {
        if (error.code == 'failed-precondition' ||
            error.code == 'invalid-argument') {
          snapshot = await collection.get();
        } else {
          rethrow;
        }
      }

      final plants = <RecentPlant>[];

      for (final document in snapshot.docs) {
        try {
          final data = document.data();

          if (data.isEmpty) {
            continue;
          }

          plants.add(
            RecentPlant.fromJson(data),
          );
        } catch (error) {
          _logger.w(
            '[RecentPlants] '
            'Skipping malformed document '
            '${document.id}: $error',
          );
        }
      }

      plants.sort(
        (a, b) => b.identifiedAt.compareTo(
          a.identifiedAt,
        ),
      );

      return plants
          .take(_maxRecentPlants)
          .toList();
    } on FirebaseException catch (error) {
      throw Exception(
        'Unable to load recent plants: '
        '${error.message ?? error.code}',
      );
    } catch (error) {
      throw Exception(
        'Unable to load recent plants.',
      );
    }
  }

  // ============================================================
  // SAVE RECENT PLANTS
  // ============================================================

  Future<void> saveRecentPlants({
    required String userId,
    required List<RecentPlant> plants,
  }) async {
    _validateUser(userId);

    try {
      final collection =
          _recentPlantsCollection(userId);

      // --------------------------------------------------------
      // SORT NEWEST FIRST
      // --------------------------------------------------------

      final sortedPlants = [...plants];

      sortedPlants.sort(
        (a, b) => b.identifiedAt.compareTo(
          a.identifiedAt,
        ),
      );

      final plantsToSave = sortedPlants
          .take(_maxRecentPlants)
          .toList();

      // --------------------------------------------------------
      // EXISTING DOCUMENTS
      // --------------------------------------------------------

      final existingSnapshot =
          await collection.get();

      // --------------------------------------------------------
      // BATCH
      // --------------------------------------------------------

      final batch = _firestore.batch();

      // --------------------------------------------------------
      // DELETE EXISTING
      //
      // We keep this only for compatibility with
      // the existing list-based save system.
      // The important part is that state is updated
      // after the operation completes.
      // --------------------------------------------------------

      for (final document
          in existingSnapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      // --------------------------------------------------------
      // CREATE DOCUMENTS
      // --------------------------------------------------------

      for (final plant in plantsToSave) {
        final document = collection.doc();

        batch.set(
          document,
          _buildFirestoreData(plant),
        );
      }

      // --------------------------------------------------------
      // COMMIT
      // --------------------------------------------------------

      await batch.commit();

      _logger.i(
        '[RecentPlants] '
        'Saved ${plantsToSave.length} recent plants.',
      );
    } on FirebaseException catch (error) {
      throw Exception(
        'Unable to save recent plants: '
        '${error.message ?? error.code}',
      );
    } catch (error) {
      throw Exception(
        'Unable to save recent plants: $error',
      );
    }
  }

  // ============================================================
  // FIRESTORE DATA
  // ============================================================

  Map<String, dynamic> _buildFirestoreData(
    RecentPlant plant,
  ) {
    final data =
        Map<String, dynamic>.from(
      plant.toJson(),
    );

    data['identifiedAt'] =
        Timestamp.fromDate(
      plant.identifiedAt,
    );

    data['savedAt'] =
        FieldValue.serverTimestamp();

    return data;
  }

  // ============================================================
  // IMAGE → BASE64
  // ============================================================

  Future<String> imageToBase64(
    Uint8List bytes,
  ) async {
    if (bytes.isEmpty) {
      throw Exception(
        'Plant image is empty.',
      );
    }

    try {
      final decodedImage =
          img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception(
          'Unable to process plant image.',
        );
      }

      final resizedImage =
          decodedImage.width > _imageMaxWidth
              ? img.copyResize(
                  decodedImage,
                  width: _imageMaxWidth,
                )
              : decodedImage;

      final compressedBytes =
          img.encodeJpg(
        resizedImage,
        quality: _imageQuality,
      );

      if (compressedBytes.isEmpty) {
        throw Exception(
          'Unable to compress plant image.',
        );
      }

      final base64Image =
          base64Encode(
        compressedBytes,
      );

      if (base64Image.isEmpty) {
        throw Exception(
          'Unable to encode plant image.',
        );
      }

      return base64Image;
    } catch (error) {
      _logger.e(
        '[RecentPlants] IMAGE CONVERSION ERROR: $error',
      );

      rethrow;
    }
  }

  // ============================================================
  // BASE64 → BYTES
  // ============================================================

  Uint8List base64ToBytes(
    String base64Image,
  ) {
    final value =
        base64Image.trim();

    if (value.isEmpty) {
      throw Exception(
        'Image data is empty.',
      );
    }

    try {
      return Uint8List.fromList(
        base64Decode(value),
      );
    } catch (_) {
      throw Exception(
        'Invalid image data.',
      );
    }
  }

  // ============================================================
  // IMAGE EXISTS
  // ============================================================

  bool imageExists(
    String? imageBase64,
  ) {
    return imageBase64 != null &&
        imageBase64.trim().isNotEmpty;
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> clearRecentPlants({
    required String userId,
  }) async {
    _validateUser(userId);

    try {
      final collection =
          _recentPlantsCollection(userId);

      final snapshot =
          await collection.get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();

      for (final document
          in snapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      await batch.commit();

      _logger.i(
        '[RecentPlants] '
        'All recent plants cleared.',
      );
    } on FirebaseException catch (error) {
      throw Exception(
        'Unable to clear recent plants: '
        '${error.message ?? error.code}',
      );
    } catch (error) {
      throw Exception(
        'Unable to clear recent plants.',
      );
    }
  }
}