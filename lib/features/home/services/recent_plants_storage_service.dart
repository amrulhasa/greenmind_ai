import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_plant.dart';

class RecentPlantsStorageService {
  static const String _storageKey =
      'recent_plants';

  // ============================================================
  // LOAD
  // ============================================================

  Future<List<RecentPlant>>
      loadRecentPlants() async {
    final preferences =
        await SharedPreferences
            .getInstance();

    final storedData =
        preferences.getString(
      _storageKey,
    );

    if (storedData == null ||
        storedData.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(storedData);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                RecentPlant.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveRecentPlants(
    List<RecentPlant> plants,
  ) async {
    final preferences =
        await SharedPreferences
            .getInstance();

    final encoded =
        jsonEncode(
      plants
          .map(
            (plant) =>
                plant.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _storageKey,
      encoded,
    );
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
        img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception(
        'Unable to process plant image.',
      );
    }

    final resizedImage =
        img.copyResize(
      decodedImage,
      width:
          decodedImage.width > 700
              ? 700
              : decodedImage.width,
    );

    final compressedBytes =
        img.encodeJpg(
      resizedImage,
      quality: 70,
    );

    return base64Encode(
      compressedBytes,
    );
  }

  // ============================================================
  // BASE64 → BYTES
  // ============================================================

  Uint8List base64ToBytes(
    String base64Image,
  ) {
    return base64Decode(
      base64Image,
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void>
      clearRecentPlants() async {
    final preferences =
        await SharedPreferences
            .getInstance();

    await preferences.remove(
      _storageKey,
    );
  }
}