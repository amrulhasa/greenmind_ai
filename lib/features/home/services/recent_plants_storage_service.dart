import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;

import '../models/recent_plant.dart';

class RecentPlantsStorageService {
  RecentPlantsStorageService();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

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
      final snapshot =
          await _recentPlantsCollection(
        userId,
      )
              .orderBy(
                'identifiedAt',
                descending: true,
              )
              .limit(5)
              .get();

      final plants =
          <RecentPlant>[];

      for (final document
          in snapshot.docs) {
        try {
          final data =
              document.data();

          final plant =
              RecentPlant.fromJson(
            data,
          );

          plants.add(
            plant,
          );
        } catch (e) {
          // Ignore malformed documents.
          continue;
        }
      }

      plants.sort(
        (a, b) =>
            b.identifiedAt.compareTo(
          a.identifiedAt,
        ),
      );

      return plants
          .take(5)
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to load recent plants: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
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
          _recentPlantsCollection(
        userId,
      );

      final limitedPlants =
          plants
              .take(5)
              .toList();

      final existingSnapshot =
          await collection.get();

      final batch =
          _firestore.batch();

      // --------------------------------------------------------
      // DELETE OLD RECORDS
      // --------------------------------------------------------

      for (final document
          in existingSnapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      // --------------------------------------------------------
      // SAVE LATEST 5 RECORDS
      // --------------------------------------------------------

      for (final plant
          in limitedPlants) {
        final document =
            collection.doc();

        final data = <
            String,
            dynamic>{
          ...plant.toJson(),

          'savedAt':
              FieldValue.serverTimestamp(),
        };

        batch.set(
          document,
          data,
        );
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to save recent plants: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(
        'Unable to save recent plants.',
      );
    }
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

    final decodedImage =
        img.decodeImage(
      bytes,
    );

    if (decodedImage == null) {
      throw Exception(
        'Unable to process plant image.',
      );
    }

    // Keep image reasonably small for Firestore.
    final resizedImage =
        decodedImage.width > 500
            ? img.copyResize(
                decodedImage,
                width: 500,
              )
            : decodedImage;

    final compressedBytes =
        img.encodeJpg(
      resizedImage,
      quality: 50,
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
  }

  // ============================================================
  // BASE64 → BYTES
  // ============================================================

  Uint8List base64ToBytes(
    String base64Image,
  ) {
    if (base64Image.isEmpty) {
      throw Exception(
        'Image data is empty.',
      );
    }

    try {
      return base64Decode(
        base64Image,
      );
    } catch (_) {
      throw Exception(
        'Invalid image data.',
      );
    }
  }

  // ============================================================
  // CHECK IMAGE
  // ============================================================

  bool imageExists(
    String? imageBase64,
  ) {
    return imageBase64 != null &&
        imageBase64.isNotEmpty;
  }

  // ============================================================
  // CLEAR RECENT PLANTS
  // ============================================================

  Future<void> clearRecentPlants({
    required String userId,
  }) async {
    _validateUser(userId);

    try {
      final collection =
          _recentPlantsCollection(
        userId,
      );

      final snapshot =
          await collection.get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch =
          _firestore.batch();

      for (final document
          in snapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to clear recent plants: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(
        'Unable to clear recent plants.',
      );
    }
  }
}