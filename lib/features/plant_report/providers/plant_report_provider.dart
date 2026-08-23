import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../identify/models/identify_result.dart';
import '../models/plant_care_report.dart';
import '../services/plant_report_service.dart';

// ============================================================================
// PROVIDER
// ============================================================================

final plantReportProvider =
    NotifierProvider<PlantReportNotifier, PlantReportState>(
  PlantReportNotifier.new,
);

// ============================================================================
// STATE
// ============================================================================

class PlantReportState {
  final bool isGenerating;
  final PlantCareReport? report;
  final String? errorMessage;

  const PlantReportState({
    this.isGenerating = false,
    this.report,
    this.errorMessage,
  });

  PlantReportState copyWith({
    bool? isGenerating,
    PlantCareReport? report,
    String? errorMessage,
    bool clearReport = false,
    bool clearError = false,
  }) {
    return PlantReportState(
      isGenerating:
          isGenerating ?? this.isGenerating,
      report: clearReport
          ? null
          : report ?? this.report,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  bool get hasReport => report != null;

  bool get hasError =>
      errorMessage != null &&
      errorMessage!.trim().isNotEmpty;
}

// ============================================================================
// NOTIFIER
// ============================================================================

class PlantReportNotifier
    extends Notifier<PlantReportState> {
  final Logger _logger = Logger();

  late PlantReportService _service;

  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instance;

  FirebaseAuth get _auth =>
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get _reportsCollection =>
          _firestore.collection('reports');

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  PlantReportState build() {
    _service = PlantReportService();

    return const PlantReportState();
  }

  // ==========================================================================
  // GENERATE IMAGE REPORT
  // ==========================================================================

  Future<void> generateImageReport({
    required IdentifyResult identification,
    required Uint8List imageBytes,
    String? imagePath,
    String? imageSource,
  }) async {
    // ------------------------------------------------------------------------
    // Prevent duplicate requests
    // ------------------------------------------------------------------------

    if (state.isGenerating) {
      _logger.d(
        'Plant report generation is already running.',
      );
      return;
    }

    // ------------------------------------------------------------------------
    // Validate authentication
    // ------------------------------------------------------------------------

    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      _setError(
        'Please login before generating a plant report.',
      );
      return;
    }

    // ------------------------------------------------------------------------
    // Validate image
    // ------------------------------------------------------------------------

    if (imageBytes.isEmpty) {
      _setError(
        'Unable to generate the report because the image is empty.',
      );
      return;
    }

    // ------------------------------------------------------------------------
    // Validate identification
    // ------------------------------------------------------------------------

    if (!identification.hasPlantName) {
      _setError(
        'A valid plant identification is required before generating the report.',
      );
      return;
    }

    // ------------------------------------------------------------------------
    // Start loading
    // ------------------------------------------------------------------------

    state = state.copyWith(
      isGenerating: true,
      clearError: true,
      clearReport: true,
    );

    _logger.i(
      'Starting GreenMind AI plant report generation.',
    );

    try {
      // ======================================================================
      // STEP 1: GENERATE AI REPORT
      // ======================================================================

      final PlantCareReport report =
          await _service.generateReportFromIdentification(
        identification: identification,
        imageBytes: imageBytes,
        imagePath: imagePath,
        imageSource: imageSource,
      );

      // ======================================================================
      // STEP 2: ATTACH IMAGE INFORMATION
      // ======================================================================

      final PlantCareReport finalReport =
          report.copyWith(
        imagePath: imagePath,
        imageBytes: imageBytes,
        generatedFromImage: true,
        imageSource: imageSource,
      );

      // ======================================================================
      // STEP 3: SAVE TO FIRESTORE
      // ======================================================================

      await _saveReportToFirestore(
        report: finalReport,
        identification: identification,
        imagePath: imagePath,
        imageSource: imageSource,
      );

      // ======================================================================
      // STEP 4: UPDATE STATE
      // ======================================================================

      state = state.copyWith(
        isGenerating: false,
        report: finalReport,
        clearError: true,
      );

      _logger.i(
        'Plant report generated and saved successfully.',
      );
    }

    // ========================================================================
    // QUOTA ERROR
    // ========================================================================

    on PlantReportQuotaException catch (error) {
      _logger.w(
        'Gemini AI quota exceeded.',
      );

      _setError(
        error.message,
      );
    }

    // ========================================================================
    // AUTHORIZATION ERROR
    // ========================================================================

    on PlantReportAuthorizationException catch (error) {
      _logger.e(
        'Gemini AI authorization failed.',
        error: error,
      );

      _setError(
        error.message,
      );
    }

    // ========================================================================
    // PLANT REPORT ERROR
    // ========================================================================

    on PlantReportException catch (error) {
      _logger.e(
        'Plant report generation failed.',
        error: error,
      );

      _setError(
        _friendlyErrorMessage(
          error.message,
        ),
      );
    }

    // ========================================================================
    // FIREBASE ERROR
    // ========================================================================

    on FirebaseException catch (error) {
      _logger.e(
        'Firebase report operation failed.',
        error: error,
      );

      _setError(
        _friendlyFirestoreError(error),
      );
    }

    // ========================================================================
    // UNKNOWN ERROR
    // ========================================================================

    catch (error, stackTrace) {
      _logger.e(
        'Unexpected plant report error.',
        error: error,
        stackTrace: stackTrace,
      );

      _setError(
        _friendlyErrorMessage(
          error.toString(),
        ),
      );
    }
  }

  // ==========================================================================
  // SAVE REPORT TO FIRESTORE
  // ==========================================================================

  Future<String> _saveReportToFirestore({
    required PlantCareReport report,
    required IdentifyResult identification,
    String? imagePath,
    String? imageSource,
  }) async {
    final User? user =
        _auth.currentUser;

    // ------------------------------------------------------------------------
    // Authentication validation
    // ------------------------------------------------------------------------

    if (user == null) {
      throw PlantReportException(
        'No authenticated user found.',
      );
    }

    // ------------------------------------------------------------------------
    // Care schedule
    // ------------------------------------------------------------------------

    final List<Map<String, dynamic>> careSchedule =
        report.careSchedule.map(
      (CareTask task) {
        return <String, dynamic>{
          'title': task.title,
          'description': task.description,
          'frequency': task.frequency,
          'icon': task.icon,
        };
      },
    ).toList();

    // ------------------------------------------------------------------------
    // New document reference
    // ------------------------------------------------------------------------

    final DocumentReference<Map<String, dynamic>>
        document =
        _reportsCollection.doc();

    // ------------------------------------------------------------------------
    // Firestore data
    // ------------------------------------------------------------------------

    final Map<String, dynamic> data =
        <String, dynamic>{
      // ======================================================================
      // REPORT INFORMATION
      // ======================================================================

      'title':
          '${report.plantName} Plant Care Report',

      'subject':
          'Plant Care Report',

      'type':
          'plant_care_report',

      'reportType':
          'AI Plant Care Report',

      // ======================================================================
      // USER
      // ======================================================================

      'userId':
          user.uid,

      'createdBy':
          user.uid,

      'email':
          user.email ?? '',

      'userDisplayName':
          user.displayName ?? '',

      // ======================================================================
      // PLANT
      // ======================================================================

      'plantName':
          report.plantName,

      'scientificName':
          report.scientificName,

      'category':
          report.category,

      // ======================================================================
      // IDENTIFICATION
      // ======================================================================

      'identificationConfidence':
          report.normalizedConfidence,

      'identificationConfidencePercentage':
          report.confidencePercentage,

      'identification':
          <String, dynamic>{
        'plantName':
            identification.plantName,
        'scientificName':
            identification.scientificName,
        'confidence':
            identification.normalizedConfidence,
        'isHealthy':
            identification.isHealthy,
      },

      // ======================================================================
      // HEALTH
      // ======================================================================

      'healthStatus':
          report.healthStatus,

      'healthScore':
          _normalizeHealthScore(
        report.normalizedHealthScore,
      ),

      // ======================================================================
      // REPORT CONTENT
      // ======================================================================

      'overview':
          report.overview,

      'description':
          report.overview,

      'sunlight':
          report.sunlight,

      'watering':
          report.watering,

      'soil':
          report.soil,

      'temperature':
          report.temperature,

      'humidity':
          report.humidity,

      'fertilizer':
          report.fertilizer,

      // ======================================================================
      // SYMPTOMS
      // ======================================================================

      'symptoms':
          List<String>.from(
        report.symptoms,
      ),

      // ======================================================================
      // RECOMMENDATIONS
      // ======================================================================

      'recommendations':
          List<String>.from(
        report.recommendations,
      ),

      'message':
          report.recommendations.join('\n'),

      // ======================================================================
      // CARE SCHEDULE
      // ======================================================================

      'careSchedule':
          careSchedule,

      // ======================================================================
      // IMAGE
      // ======================================================================

      'imagePath':
          imagePath,

      'imageSource':
          imageSource,

      'generatedFromImage':
          report.generatedFromImage,

      // ======================================================================
      // STATUS
      // ======================================================================

      'status':
          'pending',

      // ======================================================================
      // TIMESTAMPS
      // ======================================================================

      'createdAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),

      'generatedAt':
          Timestamp.fromDate(
        report.generatedAt,
      ),
    };

    // ------------------------------------------------------------------------
    // Save
    // ------------------------------------------------------------------------

    await document.set(
      data,
    );

    _logger.i(
      'Plant report saved to Firestore: ${document.id}',
    );

    return document.id;
  }

  // ==========================================================================
  // UPDATE REPORT STATUS
  // ==========================================================================

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    final String normalizedStatus =
        status.trim().toLowerCase();

    const List<String> allowedStatuses = [
      'pending',
      'reviewed',
      'resolved',
      'rejected',
    ];

    if (!allowedStatuses.contains(
      normalizedStatus,
    )) {
      throw ArgumentError(
        'Invalid report status: $status',
      );
    }

    if (reportId.trim().isEmpty) {
      throw ArgumentError(
        'Report ID cannot be empty.',
      );
    }

    try {
      await _reportsCollection
          .doc(reportId)
          .update({
        'status':
            normalizedStatus,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      _logger.i(
        'Report $reportId status updated to $normalizedStatus.',
      );
    } on FirebaseException catch (error) {
      _logger.e(
        'Failed to update report status.',
        error: error,
      );

      throw PlantReportException(
        _friendlyFirestoreError(error),
      );
    }
  }

  // ==========================================================================
  // DELETE REPORT
  // ==========================================================================

  Future<void> deleteReport(
    String reportId,
  ) async {
    if (reportId.trim().isEmpty) {
      throw ArgumentError(
        'Report ID cannot be empty.',
      );
    }

    try {
      await _reportsCollection
          .doc(reportId)
          .delete();

      _logger.i(
        'Report deleted: $reportId',
      );
    } on FirebaseException catch (error) {
      _logger.e(
        'Failed to delete report.',
        error: error,
      );

      throw PlantReportException(
        _friendlyFirestoreError(error),
      );
    }
  }

  // ==========================================================================
  // HEALTH SCORE
  // ==========================================================================

  int _normalizeHealthScore(
    num value,
  ) {
    final int score =
        value.round();

    if (score < 0) {
      return 0;
    }

    if (score > 100) {
      return 100;
    }

    return score;
  }

  // ==========================================================================
  // SET ERROR
  // ==========================================================================

  void _setError(
    String message,
  ) {
    final String cleanedMessage =
        message.trim();

    state = state.copyWith(
      isGenerating: false,
      clearReport: true,
      errorMessage:
          cleanedMessage.isEmpty
              ? 'Unable to generate the AI plant report. Please try again.'
              : cleanedMessage,
    );
  }

  // ==========================================================================
  // FIRESTORE ERROR
  // ==========================================================================

  String _friendlyFirestoreError(
    FirebaseException error,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to access the plant reports. '
            'Please check your Firestore security rules.';

      case 'unavailable':
        return 'Firestore is temporarily unavailable. '
            'Please check your internet connection and try again.';

      case 'network-request-failed':
        return 'Unable to connect to Firebase. '
            'Please check your internet connection.';

      case 'unauthenticated':
        return 'Your login session has expired. '
            'Please login again.';

      case 'not-found':
        return 'The requested report could not be found.';

      case 'failed-precondition':
        return 'This Firestore operation cannot be completed right now.';

      default:
        return 'Unable to access the plant report. '
            'Please try again.';
    }
  }

  // ==========================================================================
  // FRIENDLY ERROR MESSAGE
  // ==========================================================================

  String _friendlyErrorMessage(
    String rawMessage,
  ) {
    String message =
        rawMessage
            .replaceFirst(
              'PlantReportException: ',
              '',
            )
            .replaceFirst(
              'Exception: ',
              '',
            )
            .trim();

    if (message.isEmpty) {
      return 'Unable to generate the AI plant report. '
          'Please try again.';
    }

    final String lower =
        message.toLowerCase();

    // ------------------------------------------------------------------------
    // QUOTA
    // ------------------------------------------------------------------------

    if (lower.contains('quota') ||
        lower.contains('resource exhausted') ||
        lower.contains('rate limit') ||
        lower.contains('free-tier') ||
        lower.contains('free tier') ||
        lower.contains(
          'generate_content_free_tier_requests',
        ) ||
        lower.contains('429')) {
      return 'Gemini AI usage limit has been reached. '
          'Please wait a little and try again.';
    }

    // ------------------------------------------------------------------------
    // NETWORK
    // ------------------------------------------------------------------------

    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('timeout') ||
        lower.contains('timed out')) {
      return 'Unable to connect to GreenMind AI. '
          'Please check your internet connection and try again.';
    }

    // ------------------------------------------------------------------------
    // AUTHORIZATION
    // ------------------------------------------------------------------------

    if (lower.contains('permission-denied') ||
        lower.contains('permission denied') ||
        lower.contains('unauthenticated') ||
        lower.contains('unauthorized') ||
        lower.contains('authentication')) {
      return 'GreenMind AI is not authorized correctly. '
          'Please check your Firebase AI configuration.';
    }

    // ------------------------------------------------------------------------
    // INVALID RESPONSE
    // ------------------------------------------------------------------------

    if (lower.contains('json') ||
        lower.contains('invalid ai report') ||
        lower.contains('empty report') ||
        lower.contains('incomplete plant report')) {
      return 'GreenMind AI returned an incomplete report. '
          'Please try the image again.';
    }

    // ------------------------------------------------------------------------
    // IMAGE
    // ------------------------------------------------------------------------

    if (lower.contains('image') &&
        (lower.contains('empty') ||
            lower.contains('unsupported') ||
            lower.contains('format'))) {
      return message;
    }

    return message;
  }

  // ==========================================================================
  // CLEAR REPORT
  // ==========================================================================

  void clearReport() {
    state = const PlantReportState();
  }

  // ==========================================================================
  // CLEAR ERROR
  // ==========================================================================

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }
}