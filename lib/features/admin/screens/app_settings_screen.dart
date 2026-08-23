import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_settings_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({
    super.key,
  });

  @override
  ConsumerState<AppSettingsScreen> createState() =>
      _AppSettingsScreenState();
}

class _AppSettingsScreenState
    extends ConsumerState<AppSettingsScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  late final TextEditingController _applicationNameController;
  late final TextEditingController _descriptionController;

  // ============================================================
  // LOCAL STATE
  // ============================================================

  bool _initialized = false;
  bool _hasChanges = false;

  bool _maintenanceMode = false;

  bool _plantIdentificationEnabled = true;
  bool _diseaseDetectionEnabled = true;

  double _aiConfidenceThreshold = 70;

  bool _announcementsEnabled = true;
  bool _remindersEnabled = true;

  bool _userRegistrationEnabled = true;
  bool _accountDeletionEnabled = true;

  bool _supportEnabled = true;
  bool _isPublic = true;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _applicationNameController =
        TextEditingController();

    _descriptionController =
        TextEditingController();

    _applicationNameController.addListener(
      _markAsChanged,
    );

    _descriptionController.addListener(
      _markAsChanged,
    );
  }

  @override
  void dispose() {
    _applicationNameController
        .removeListener(_markAsChanged);

    _descriptionController
        .removeListener(_markAsChanged);

    _applicationNameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // INITIALIZE FORM
  // ============================================================

  void _initializeFromSettings(
    Map<String, dynamic> settings,
  ) {
    if (_initialized) {
      return;
    }

    _applicationNameController.text =
        _stringValue(
      settings['applicationName'],
      fallback: 'GreenMind AI',
    );

    _descriptionController.text =
        _stringValue(
      settings['appDescription'],
      fallback:
          'AI Powered Plant Identification & Smart Care Assistant',
    );

    _maintenanceMode =
        _boolValue(
      settings['maintenanceMode'],
      fallback: false,
    );

    _plantIdentificationEnabled =
        _boolValue(
      settings['plantIdentificationEnabled'],
      fallback: true,
    );

    _diseaseDetectionEnabled =
        _boolValue(
      settings['diseaseDetectionEnabled'],
      fallback: true,
    );

    _aiConfidenceThreshold =
        _doubleValue(
      settings['aiConfidenceThreshold'],
      fallback: 70,
    ).clamp(0, 100);

    _announcementsEnabled =
        _boolValue(
      settings['announcementsEnabled'],
      fallback: true,
    );

    _remindersEnabled =
        _boolValue(
      settings['remindersEnabled'],
      fallback: true,
    );

    _userRegistrationEnabled =
        _boolValue(
      settings['userRegistrationEnabled'],
      fallback: true,
    );

    _accountDeletionEnabled =
        _boolValue(
      settings['accountDeletionEnabled'],
      fallback: true,
    );

    _supportEnabled =
        _boolValue(
      settings['supportEnabled'],
      fallback: true,
    );

    _isPublic =
        _boolValue(
      settings['isPublic'],
      fallback: true,
    );

    _initialized = true;
    _hasChanges = false;
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  String _stringValue(
    dynamic value, {
    required String fallback,
  }) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallback;
  }

  bool _boolValue(
    dynamic value, {
    required bool fallback,
  }) {
    if (value is bool) {
      return value;
    }

    return fallback;
  }

  double _doubleValue(
    dynamic value, {
    required double fallback,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    return fallback;
  }

  // ============================================================
  // CHANGE TRACKING
  // ============================================================

  void _markAsChanged() {
    if (!_initialized) {
      return;
    }

    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _setChanged(
    VoidCallback callback,
  ) {
    setState(() {
      callback();
      _hasChanges = true;
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveSettings() async {
    FocusScope.of(context).unfocus();

    final String applicationName =
        _applicationNameController.text.trim();

    final String description =
        _descriptionController.text.trim();

    if (applicationName.isEmpty) {
      _showMessage(
        'Application name cannot be empty.',
        isError: true,
      );
      return;
    }

    final Map<String, dynamic> settings = {
      // ----------------------------------------------------------
      // GENERAL
      // ----------------------------------------------------------

      'applicationName': applicationName,

      'appDescription': description,

      // ----------------------------------------------------------
      // ACCESS
      // ----------------------------------------------------------

      'maintenanceMode': _maintenanceMode,

      'userRegistrationEnabled':
          _userRegistrationEnabled,

      'accountDeletionEnabled':
          _accountDeletionEnabled,

      // ----------------------------------------------------------
      // AI FEATURES
      // ----------------------------------------------------------

      'plantIdentificationEnabled':
          _plantIdentificationEnabled,

      'diseaseDetectionEnabled':
          _diseaseDetectionEnabled,

      'aiConfidenceThreshold':
          _aiConfidenceThreshold.round(),

      // ----------------------------------------------------------
      // COMMUNICATION
      // ----------------------------------------------------------

      'announcementsEnabled':
          _announcementsEnabled,

      'remindersEnabled':
          _remindersEnabled,

      // ----------------------------------------------------------
      // SUPPORT / VISIBILITY
      // ----------------------------------------------------------

      'supportEnabled':
          _supportEnabled,

      'isPublic':
          _isPublic,
    };

    final bool success =
        await ref
            .read(
              appSettingsProvider.notifier,
            )
            .save(settings);

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        _hasChanges = false;
      });

      _showMessage(
        'Application settings saved successfully.',
      );
    } else {
      final String? error =
          ref.read(appSettingsProvider).error;

      _showMessage(
        error ?? 'Failed to save settings.',
        isError: true,
      );
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> _resetSettings() async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Reset settings?',
          ),
          content: const Text(
            'All application settings will be '
            'restored to their default values.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Reset',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool success =
        await ref
            .read(
              appSettingsProvider.notifier,
            )
            .reset();

    if (!mounted) {
      return;
    }

    if (success) {
      _initialized = false;

      setState(() {
        _hasChanges = false;
      });

      _showMessage(
        'Settings restored to defaults.',
      );
    } else {
      final String? error =
          ref.read(appSettingsProvider).error;

      _showMessage(
        error ?? 'Failed to reset settings.',
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? const Color(0xFFB42318)
              : const Color(0xFF287C35),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppSettingsState state =
        ref.watch(appSettingsProvider);

    if (state.isLoading &&
        state.settings.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F8F4),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.settings.isNotEmpty) {
      _initializeFromSettings(
        state.settings,
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(
              state,
            ),
            Expanded(
              child: _buildContent(
                state,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(
    AppSettingsState state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFEAF3E7),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD9E5D5),
          ),
        ),
      ),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'App Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E251F),
              ),
            ),
          ),
          if (_hasChanges)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFFD89B00),
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Unsaved changes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF765500),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          if (state.isSaving)
            const SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            )
          else
            _iconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Reset settings',
              onPressed: _resetSettings,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
    AppSettingsState state,
  ) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final double width =
            constraints.maxWidth;

        final double contentWidth =
            width > 1150
                ? 1050
                : width > 760
                    ? width - 48
                    : width - 32;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 34,
            bottom: 40,
          ),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(),
                  const SizedBox(height: 30),

                  _buildGeneralSection(),
                  const SizedBox(height: 20),

                  _buildAccessSection(),
                  const SizedBox(height: 20),

                  _buildAiSection(),
                  const SizedBox(height: 20),

                  _buildCommunicationSection(),
                  const SizedBox(height: 20),

                  _buildSupportSection(),
                  const SizedBox(height: 30),

                  _buildSaveButton(
                    state,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Settings',
          style: TextStyle(
            fontSize: 34,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: Color(0xFF182019),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Configure general settings and application behaviour '
          'for GreenMind AI.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GENERAL SECTION
  // ============================================================

  Widget _buildGeneralSection() {
    return _SettingsCard(
      icon: Icons.tune_rounded,
      title: 'General',
      subtitle:
          'Basic information about your application.',
      children: [
        _buildTextField(
          controller:
              _applicationNameController,
          label: 'Application Name',
          hint: 'GreenMind AI',
          icon:
              Icons.apps_rounded,
        ),
        const SizedBox(height: 18),
        _buildTextField(
          controller:
              _descriptionController,
          label: 'Application Description',
          hint:
              'AI Powered Plant Identification & Smart Care Assistant',
          icon:
              Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  // ============================================================
  // ACCESS SECTION
  // ============================================================

  Widget _buildAccessSection() {
    return _SettingsCard(
      icon: Icons.people_alt_outlined,
      title: 'User Access',
      subtitle:
          'Control registration and account-related behaviour.',
      children: [
        _buildSwitchTile(
          icon:
              Icons.person_add_alt_1_outlined,
          title: 'Allow Registration',
          description:
              'Allow new users to create accounts.',
          value:
              _userRegistrationEnabled,
          onChanged: (bool value) {
            _setChanged(() {
              _userRegistrationEnabled =
                  value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon:
              Icons.delete_outline_rounded,
          title: 'Account Deletion',
          description:
              'Allow users to permanently delete their accounts.',
          value:
              _accountDeletionEnabled,
          onChanged: (bool value) {
            _setChanged(() {
              _accountDeletionEnabled =
                  value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon:
              Icons.build_circle_outlined,
          title: 'Maintenance Mode',
          description:
              'Temporarily restrict access while maintenance is in progress.',
          value: _maintenanceMode,
          warning: _maintenanceMode,
          onChanged: (bool value) {
            _setChanged(() {
              _maintenanceMode = value;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // AI SECTION
  // ============================================================

  Widget _buildAiSection() {
    return _SettingsCard(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Features',
      subtitle:
          'Configure the intelligent features of GreenMind AI.',
      children: [
        _buildSwitchTile(
          icon:
              Icons.local_florist_outlined,
          title: 'Plant Identification',
          description:
              'Enable AI-powered plant identification.',
          value:
              _plantIdentificationEnabled,
          onChanged: (bool value) {
            _setChanged(() {
              _plantIdentificationEnabled =
                  value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon:
              Icons.health_and_safety_outlined,
          title: 'Disease Detection',
          description:
              'Enable AI-powered plant disease detection.',
          value:
              _diseaseDetectionEnabled,
          onChanged: (bool value) {
            _setChanged(() {
              _diseaseDetectionEnabled =
                  value;
            });
          },
        ),
        const SizedBox(height: 22),
        _buildConfidenceSlider(),
      ],
    );
  }

  // ============================================================
  // CONFIDENCE SLIDER
  // ============================================================

  Widget _buildConfidenceSlider() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E8DC),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                size: 21,
                color: Color(0xFF287C35),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'AI Confidence Threshold',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202620),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE7F3E4),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Text(
                  '${_aiConfidenceThreshold.round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(0xFF287C35),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum confidence required before an AI result is shown.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value:
                _aiConfidenceThreshold,
            min: 0,
            max: 100,
            divisions: 100,
            label:
                '${_aiConfidenceThreshold.round()}%',
            onChanged: (double value) {
              _setChanged(() {
                _aiConfidenceThreshold =
                    value;
              });
            },
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: TextStyle(
                  fontSize: 11,
                  color:
                      Colors.grey.shade500,
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  fontSize: 11,
                  color:
                      Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMUNICATION SECTION
  // ============================================================

  Widget _buildCommunicationSection() {
    return _SettingsCard(
      icon:
          Icons.notifications_none_rounded,
      title: 'Communication',
      subtitle:
          'Manage announcements and reminder functionality.',
      children: [
        _buildSwitchTile(
          icon:
              Icons.campaign_outlined,
          title: 'Announcements',
          description:
              'Enable application-wide announcements.',
          value:
              _announcementsEnabled,
          onChanged: (bool value) {
            _setChanged(() {
              _announcementsEnabled =
                  value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon:
              Icons.notifications_active_outlined,
          title: 'Reminders',
          description:
              'Enable smart care reminders and notifications.',
          value:
              _remindersEnabled,
          onChanged: (bool value) {
            _setChanged(() {
              _remindersEnabled =
                  value;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // SUPPORT SECTION
  // ============================================================

  Widget _buildSupportSection() {
    return _SettingsCard(
      icon:
          Icons.support_agent_rounded,
      title: 'Support & Visibility',
      subtitle:
          'Control support availability and application visibility.',
      children: [
        _buildSwitchTile(
          icon:
              Icons.support_agent_outlined,
          title: 'Support',
          description:
              'Enable user support and help functionality.',
          value:
              _supportEnabled,
          onChanged: (bool value) {
            _setChanged(() {
              _supportEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon:
              Icons.public_rounded,
          title: 'Public Application',
          description:
              'Allow the application to be publicly accessible.',
          value: _isPublic,
          onChanged: (bool value) {
            _setChanged(() {
              _isPublic = value;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton(
    AppSettingsState state,
  ) {
    final bool disabled =
        state.isSaving ||
        !_hasChanges;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed:
            disabled ? null : _saveSettings,
        icon: state.isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.save_outlined,
              ),
        label: Text(
          state.isSaving
              ? 'Saving Settings...'
              : 'Save Settings',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor:
              const Color(0xFF2E8438),
          disabledBackgroundColor:
              const Color(0xFFD9E3D6),
          disabledForegroundColor:
              const Color(0xFF849084),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 14,
            right: 10,
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFF4E5A50),
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(
          minWidth: 52,
        ),
        filled: true,
        fillColor:
            const Color(0xFFFBFCFA),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD6DED3),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD6DED3),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: Color(0xFF2E8438),
            width: 1.6,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool warning = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: warning
                  ? const Color(0xFFFFF1D8)
                  : const Color(0xFFEAF4E7),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 21,
              color: warning
                  ? const Color(0xFFB77900)
                  : const Color(0xFF287C35),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(0xFF202620),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor:
                const Color(0xFF2E8438),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: Color(0xFFE0E6DE),
      ),
    );
  }

  // ============================================================
  // ICON BUTTON
  // ============================================================

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius:
              BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF8FAF7),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color:
                    const Color(0xFFD7E1D4),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  const Color(0xFF39443B),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SETTINGS CARD
// ==================================================================

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFB),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6DFD3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1D2A1F),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE7F2E3),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF287C35),
                  size: 23,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF1F2720),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }
}