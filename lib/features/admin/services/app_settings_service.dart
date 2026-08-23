import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppSettingsService {
  AppSettingsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth =
            auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ============================================================
  // FIRESTORE LOCATION
  //
  // app_settings
  //      └── general
  // ============================================================

  DocumentReference<Map<String, dynamic>>
      get _settingsDocument {
    return _firestore
        .collection('app_settings')
        .doc('general');
  }

  // ============================================================
  // DEFAULT SETTINGS
  // ============================================================

  Map<String, dynamic> get defaults {
    return <String, dynamic>{
      'applicationName': 'GreenMind AI',

      'appDescription':
          'AI-powered plant identification and smart care assistant.',

      'maintenanceMode': false,

      'plantIdentificationEnabled': true,

      'diseaseDetectionEnabled': true,

      'aiConfidenceThreshold': 70,

      'announcementsEnabled': true,

      'remindersEnabled': true,

      'userRegistrationEnabled': true,

      'accountDeletionEnabled': true,

      'supportEnabled': true,

      'isPublic': true,
    };
  }

  // ============================================================
  // GET SETTINGS
  // ============================================================

  Future<Map<String, dynamic>> getSettings() async {
    final DocumentSnapshot<Map<String, dynamic>>
        snapshot =
        await _settingsDocument.get();

    if (!snapshot.exists ||
        snapshot.data() == null) {
      return Map<String, dynamic>.from(
        defaults,
      );
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(
      snapshot.data()!,
    );

    return <String, dynamic>{
      ...defaults,
      ...data,
    };
  }

  // ============================================================
  // WATCH SETTINGS
  // ============================================================

  Stream<Map<String, dynamic>> watchSettings() {
    return _settingsDocument.snapshots().map(
      (
        DocumentSnapshot<Map<String, dynamic>>
            snapshot,
      ) {
        if (!snapshot.exists ||
            snapshot.data() == null) {
          return Map<String, dynamic>.from(
            defaults,
          );
        }

        return <String, dynamic>{
          ...defaults,
          ...snapshot.data()!,
        };
      },
    );
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> saveSettings(
    Map<String, dynamic> settings,
  ) async {
    final User? user =
        _auth.currentUser;

    final Map<String, dynamic> data =
        <String, dynamic>{
      ...settings,

      'updatedAt':
          FieldValue.serverTimestamp(),

      'updatedBy':
          user?.uid,
    };

    await _settingsDocument.set(
      data,
      SetOptions(
        merge: true,
      ),
    );
  }

  // ============================================================
  // RESET TO DEFAULTS
  // ============================================================

  Future<void> resetToDefaults() async {
    final User? user =
        _auth.currentUser;

    await _settingsDocument.set(
      <String, dynamic>{
        ...defaults,

        'updatedAt':
            FieldValue.serverTimestamp(),

        'updatedBy':
            user?.uid,
      },
      SetOptions(
        merge: true,
      ),
    );
  }
}