import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_log_service.dart';
import '../services/app_settings_service.dart';

// ============================================================
// APP SETTINGS SERVICE PROVIDER
// ============================================================

final appSettingsServiceProvider =
    Provider<AppSettingsService>(
  (ref) {
    return AppSettingsService();
  },
);

// ============================================================
// APP SETTINGS STATE
// ============================================================

class AppSettingsState {
  const AppSettingsState({
    this.settings =
        const <String, dynamic>{},
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final Map<String, dynamic> settings;

  final bool isLoading;

  final bool isSaving;

  final String? error;

  AppSettingsState copyWith({
    Map<String, dynamic>? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return AppSettingsState(
      settings:
          settings ?? this.settings,

      isLoading:
          isLoading ?? this.isLoading,

      isSaving:
          isSaving ?? this.isSaving,

      error:
          clearError
              ? null
              : error ?? this.error,
    );
  }
}

// ============================================================
// APP SETTINGS PROVIDER
// ============================================================

final appSettingsProvider =
    NotifierProvider<
        AppSettingsNotifier,
        AppSettingsState>(
  AppSettingsNotifier.new,
);

// ============================================================
// APP SETTINGS NOTIFIER
// ============================================================

class AppSettingsNotifier
    extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    Future.microtask(load);

    return const AppSettingsState();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> load() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final AppSettingsService
          service =
          ref.read(
        appSettingsServiceProvider,
      );

      final Map<String, dynamic>
          settings =
          await service.getSettings();

      state = state.copyWith(
        settings:
            Map<String, dynamic>.from(
          settings,
        ),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<bool> save(
    Map<String, dynamic> settings,
  ) async {
    if (state.isSaving) {
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
    );

    try {
      final Map<String, dynamic>
          cleanSettings =
          <String, dynamic>{
        'applicationName':
            settings['applicationName']
                    ?.toString()
                    .trim() ??
                'GreenMind AI',

        'appDescription':
            settings['appDescription']
                    ?.toString()
                    .trim() ??
                '',

        'maintenanceMode':
            settings[
                    'maintenanceMode'] ==
                true,

        'plantIdentificationEnabled':
            settings[
                    'plantIdentificationEnabled'] ==
                true,

        'diseaseDetectionEnabled':
            settings[
                    'diseaseDetectionEnabled'] ==
                true,

        'aiConfidenceThreshold':
            _normalizeConfidence(
          settings[
              'aiConfidenceThreshold'],
        ),

        'announcementsEnabled':
            settings[
                    'announcementsEnabled'] ==
                true,

        'remindersEnabled':
            settings[
                    'remindersEnabled'] ==
                true,

        'userRegistrationEnabled':
            settings[
                    'userRegistrationEnabled'] ==
                true,

        'accountDeletionEnabled':
            settings[
                    'accountDeletionEnabled'] ==
                true,

        'supportEnabled':
            settings[
                    'supportEnabled'] ==
                true,

        'isPublic':
            settings['isPublic'] ==
                true,
      };

      // --------------------------------------------------------
      // SAVE FIRESTORE
      // --------------------------------------------------------

      await ref
          .read(
            appSettingsServiceProvider,
          )
          .saveSettings(
        cleanSettings,
      );

      // --------------------------------------------------------
      // ADMIN LOG
      // --------------------------------------------------------

      await ref
          .read(
            adminLogServiceProvider,
          )
          .createLog(
        action: 'settings_updated',

        category: 'settings',

        description:
            'Application settings were updated.',

        targetType:
            'app_settings',

        targetId:
            'general',

        metadata:
            cleanSettings,
      );

      // --------------------------------------------------------
      // UPDATE LOCAL STATE
      // --------------------------------------------------------

      state = state.copyWith(
        settings:
            Map<String, dynamic>.from(
          cleanSettings,
        ),
        isSaving: false,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        error: error.toString(),
      );

      return false;
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<bool> reset() async {
    if (state.isSaving) {
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
    );

    try {
      final AppSettingsService
          service =
          ref.read(
        appSettingsServiceProvider,
      );

      await service.resetToDefaults();

      final Map<String, dynamic>
          settings =
          await service.getSettings();

      // --------------------------------------------------------
      // ADMIN LOG
      // --------------------------------------------------------

      await ref
          .read(
            adminLogServiceProvider,
          )
          .createLog(
        action: 'settings_reset',

        category: 'settings',

        description:
            'Application settings were reset to defaults.',

        targetType:
            'app_settings',

        targetId:
            'general',
      );

      // --------------------------------------------------------
      // LOCAL STATE
      // --------------------------------------------------------

      state = state.copyWith(
        settings:
            Map<String, dynamic>.from(
          settings,
        ),
        isSaving: false,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        error: error.toString(),
      );

      return false;
    }
  }

  // ============================================================
  // CONFIDENCE NORMALIZER
  // ============================================================

  int _normalizeConfidence(
    dynamic value,
  ) {
    if (value is num) {
      return value
          .round()
          .clamp(0, 100);
    }

    return 70;
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }
}