import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminAppSettingsScreen
    extends StatefulWidget {
  const AdminAppSettingsScreen({
    super.key,
  });

  @override
  State<AdminAppSettingsScreen> createState() =>
      _AdminAppSettingsScreenState();
}

class _AdminAppSettingsScreenState
    extends State<AdminAppSettingsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isSaving = false;

  bool _maintenanceMode = false;
  bool _allowRegistration = true;
  bool _announcementsEnabled = true;
  bool _supportEnabled = true;

  String _appName = 'GreenMind AI';

  // ============================================================
  // FIRESTORE REFERENCE
  // ============================================================

  DocumentReference<
      Map<String, dynamic>>
  get _settingsReference {
    return _firestore
        .collection('app_settings')
        .doc('general');
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final DocumentSnapshot<
          Map<String, dynamic>> snapshot =
          await _settingsReference.get();

      if (snapshot.exists) {
        final Map<String, dynamic> data =
            snapshot.data() ??
                <String, dynamic>{};

        _appName =
            data['appName']?.toString() ??
                'GreenMind AI';

        _maintenanceMode =
            data['maintenanceMode'] == true;

        _allowRegistration =
            data['allowRegistration'] != false;

        _announcementsEnabled =
            data['announcementsEnabled'] !=
                false;

        _supportEnabled =
            data['supportEnabled'] != false;
      }
    } catch (error) {
      debugPrint(
        'LOAD APP SETTINGS ERROR: $error',
      );

      if (mounted) {
        _showMessage(
          'Unable to load application settings.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> _saveSettings() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user =
          _auth.currentUser;

      final String? adminUid =
          user?.uid;

      await _settingsReference.set(
        <String, dynamic>{
          'appName': _appName.trim().isEmpty
              ? 'GreenMind AI'
              : _appName.trim(),

          'maintenanceMode':
              _maintenanceMode,

          'allowRegistration':
              _allowRegistration,

          'announcementsEnabled':
              _announcementsEnabled,

          'supportEnabled':
              _supportEnabled,

          'updatedAt':
              FieldValue.serverTimestamp(),

          'updatedBy':
              adminUid,
        },
        SetOptions(
          merge: true,
        ),
      );

      await _createAdminLog(
        action: 'Updated application settings',
        details:
            'Application settings were modified from the Admin Settings panel.',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Application settings saved successfully.',
      );
    } catch (error) {
      debugPrint(
        'SAVE APP SETTINGS ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to save settings. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // ADMIN LOG
  // ============================================================

  Future<void> _createAdminLog({
    required String action,
    required String details,
  }) async {
    try {
      final User? user =
          _auth.currentUser;

      await _firestore
          .collection('admin_logs')
          .add(
        <String, dynamic>{
          'action': action,
          'details': details,
          'adminUid': user?.uid,
          'adminEmail': user?.email,
          'createdAt':
              FieldValue.serverTimestamp(),
        },
      );
    } catch (error) {
      debugPrint(
        'CREATE ADMIN LOG ERROR: $error',
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
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              isError
                  ? Colors.red.shade700
                  : AppColors.primary,
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
    return Scaffold(
      backgroundColor:
          Theme.of(context)
              .scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'App Settings',
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SafeArea(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 900,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================

                        Text(
                          'Application Settings',
                          style:
                              AppTextStyles
                                  .heading1,
                        ),

                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),

                        Text(
                          'Configure general settings for the GreenMind AI application.',
                          style:
                              AppTextStyles
                                  .subtitle,
                        ),

                        const SizedBox(
                          height:
                              AppSpacing.xl,
                        ),

                        // ==================================================
                        // GENERAL
                        // ==================================================

                        _SettingsSection(
                          title:
                              'General',
                          icon:
                              Icons
                                  .tune_rounded,
                          child:
                              Column(
                            children: [
                              TextFormField(
                                initialValue:
                                    _appName,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      'Application Name',
                                  hintText:
                                      'Enter application name',
                                  prefixIcon:
                                      Icon(
                                    Icons
                                        .apps_rounded,
                                  ),
                                  border:
                                      OutlineInputBorder(),
                                ),
                                onChanged:
                                    (String value) {
                                  _appName =
                                      value;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ==================================================
                        // USER ACCESS
                        // ==================================================

                        _SettingsSection(
                          title:
                              'User Access',
                          icon:
                              Icons
                                  .people_alt_rounded,
                          child:
                              Column(
                            children: [
                              _SettingsSwitch(
                                title:
                                    'Allow Registration',
                                subtitle:
                                    'Allow new users to create accounts.',
                                value:
                                    _allowRegistration,
                                onChanged:
                                    (bool value) {
                                  setState(() {
                                    _allowRegistration =
                                        value;
                                  });
                                },
                              ),

                              const Divider(
                                height: 1,
                              ),

                              _SettingsSwitch(
                                title:
                                    'Maintenance Mode',
                                subtitle:
                                    'Temporarily place the application into maintenance mode.',
                                value:
                                    _maintenanceMode,
                                onChanged:
                                    (bool value) {
                                  setState(() {
                                    _maintenanceMode =
                                        value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ==================================================
                        // FEATURES
                        // ==================================================

                        _SettingsSection(
                          title:
                              'Application Features',
                          icon:
                              Icons
                                  .apps_rounded,
                          child:
                              Column(
                            children: [
                              _SettingsSwitch(
                                title:
                                    'Announcements',
                                subtitle:
                                    'Enable announcement functionality.',
                                value:
                                    _announcementsEnabled,
                                onChanged:
                                    (bool value) {
                                  setState(() {
                                    _announcementsEnabled =
                                        value;
                                  });
                                },
                              ),

                              const Divider(
                                height: 1,
                              ),

                              _SettingsSwitch(
                                title:
                                    'Support',
                                subtitle:
                                    'Enable user support functionality.',
                                value:
                                    _supportEnabled,
                                onChanged:
                                    (bool value) {
                                  setState(() {
                                    _supportEnabled =
                                        value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // SAVE
                        // ==================================================

                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              ElevatedButton.icon(
                            onPressed:
                                _isSaving
                                    ? null
                                    : _saveSettings,
                            icon:
                                _isSaving
                                    ? const SizedBox(
                                        width:
                                            19,
                                        height:
                                            19,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons
                                            .save_rounded,
                                      ),
                            label:
                                Text(
                              _isSaving
                                  ? 'Saving...'
                                  : 'Save Settings',
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  AppColors
                                      .primary,
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ==================================================================
// SETTINGS SECTION
// ==================================================================

class _SettingsSection
    extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              Theme.of(context)
                  .dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Text(
                title,
                style:
                    AppTextStyles.heading3,
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          child,
        ],
      ),
    );
  }
}

// ==================================================================
// SETTINGS SWITCH
// ==================================================================

class _SettingsSwitch
    extends StatelessWidget {
  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(
    BuildContext context,
  ) {
    return SwitchListTile.adaptive(
      contentPadding:
          EdgeInsets.zero,
      title: Text(
        title,
        style:
            const TextStyle(
          fontWeight:
              FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding:
            const EdgeInsets.only(
          top: 4,
        ),
        child: Text(
          subtitle,
          style:
              const TextStyle(
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
      value: value,
        activeThumbColor:
          AppColors.primary,
      onChanged: onChanged,
    );
  }
}