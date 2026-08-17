import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/plant_reminder.dart';
import '../providers/reminder_provider.dart';

class ReminderForm extends ConsumerStatefulWidget {
  const ReminderForm({
    super.key,
  });

  @override
  ConsumerState<ReminderForm> createState() =>
      _ReminderFormState();
}

class _ReminderFormState
    extends ConsumerState<ReminderForm> {
  // ============================================================
  // FORM
  // ============================================================

  final _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _plantController =
      TextEditingController();

  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  // ============================================================
  // REMINDER SETTINGS
  // ============================================================

  ReminderType _selectedType =
      ReminderType.watering;

  ReminderMode _selectedMode =
      ReminderMode.notification;

  DateTime _selectedDateTime =
      DateTime.now().add(
    const Duration(
      hours: 1,
    ),
  );

  // ============================================================
  // SOUND
  // ============================================================

  String? _selectedSoundPath;

  String? _selectedSoundName;

  bool _isSelectingSound =
      false;

  bool _isCreating =
      false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _plantController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final now =
        DateTime.now();

    final initialDate =
        _selectedDateTime.isBefore(now)
            ? DateTime(
                now.year,
                now.month,
                now.day,
              )
            : _selectedDateTime;

    final date =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: now.add(
        const Duration(
          days: 3650,
        ),
      ),
      helpText:
          'Select reminder date',
      cancelText:
          'Cancel',
      confirmText:
          'Select',
    );

    if (date == null ||
        !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime =
          DateTime(
        date.year,
        date.month,
        date.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> _selectTime() async {
    final time =
        await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(
        _selectedDateTime,
      ),
      helpText:
          'Select reminder time',
      cancelText:
          'Cancel',
      confirmText:
          'Select',
    );

    if (time == null ||
        !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime =
          DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ============================================================
  // PICK CUSTOM AUDIO
  // ============================================================

  Future<void> _pickSound() async {
    if (kIsWeb) {
      _showMessage(
        'Custom alarm music is available on Android/iOS.',
      );
      return;
    }

    if (_isSelectingSound) {
      return;
    }

    setState(() {
      _isSelectingSound =
          true;
    });

    try {
      // ========================================================
      // FILE PICKER 12+
      //
      // pickFile() is specifically for single-file selection.
      // No allowMultiple is required.
      // ========================================================

      final PlatformFile? pickedFile =
          await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const [
          'mp3',
          'wav',
          'm4a',
          'aac',
          'ogg',
        ],
      );

      if (pickedFile == null) {
        return;
      }

      // ========================================================
      // READ FILE DATA
      //
      // Do NOT depend only on pickedFile.path.
      //
      // This is important for Android files selected from:
      // - Gallery/file provider
      // - Downloads
      // - Google Drive
      // - Other document providers
      //
      // readAsBytes() is safer here.
      // ========================================================

      final Uint8List bytes =
          await pickedFile.readAsBytes();

      if (bytes.isEmpty) {
        _showMessage(
          'Selected audio file is empty.',
        );
        return;
      }

      // ========================================================
      // APP DOCUMENT DIRECTORY
      // ========================================================

      final appDirectory =
          await getApplicationDocumentsDirectory();

      final soundDirectory =
          Directory(
        '${appDirectory.path}/reminder_sounds',
      );

      if (!await soundDirectory.exists()) {
        await soundDirectory.create(
          recursive: true,
        );
      }

      // ========================================================
      // EXTENSION
      // ========================================================

      final extension =
          _fileExtension(
        pickedFile.name,
      );

      // ========================================================
      // UNIQUE FILE NAME
      // ========================================================

      final safeFileName =
          'reminder_sound_'
          '${DateTime.now().microsecondsSinceEpoch}'
          '$extension';

      final destinationPath =
          '${soundDirectory.path}/'
          '$safeFileName';

      final destinationFile =
          File(destinationPath);

      // ========================================================
      // WRITE FILE
      // ========================================================

      await destinationFile.writeAsBytes(
        bytes,
        flush: true,
      );

      // ========================================================
      // VERIFY
      // ========================================================

      if (!await destinationFile.exists()) {
        _showMessage(
          'Unable to save the selected music.',
        );
        return;
      }

      final savedSize =
          await destinationFile.length();

      if (savedSize <= 0) {
        _showMessage(
          'Saved music file is empty.',
        );
        return;
      }

      // ========================================================
      // DELETE OLD SOUND
      // ========================================================

      final oldPath =
          _selectedSoundPath;

      if (oldPath != null &&
          oldPath.trim().isNotEmpty &&
          oldPath != destinationFile.path) {
        try {
          final oldFile =
              File(oldPath);

          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (_) {
          // Ignore old file cleanup failure.
        }
      }

      // ========================================================
      // UPDATE STATE
      // ========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedSoundPath =
            destinationFile.path;

        _selectedSoundName =
            pickedFile.name;
      });

      _showMessage(
        'Music selected successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to select music.\n'
        '${_cleanError(e)}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingSound =
              false;
        });
      }
    }
  }

  // ============================================================
  // REMOVE CUSTOM SOUND
  // ============================================================

  Future<void> _removeSound() async {
    final path =
        _selectedSoundPath;

    if (mounted) {
      setState(() {
        _selectedSoundPath =
            null;

        _selectedSoundName =
            null;
      });
    }

    if (path == null ||
        path.trim().isEmpty ||
        kIsWeb) {
      return;
    }

    try {
      final file =
          File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup failure.
    }
  }

  // ============================================================
  // USE DEFAULT ALARM
  // ============================================================

  Future<void> _useDefaultAlarm() async {
    final oldPath =
        _selectedSoundPath;

    // ==========================================================
    // IMPORTANT
    //
    // null soundPath means:
    // Device default alarm sound.
    //
    // alarm package 5.4.1 supports this behaviour.
    // ==========================================================

    if (mounted) {
      setState(() {
        _selectedSoundPath =
            null;

        _selectedSoundName =
            null;
      });
    }

    if (oldPath == null ||
        oldPath.trim().isEmpty ||
        kIsWeb) {
      return;
    }

    try {
      final oldFile =
          File(oldPath);

      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    } catch (_) {
      // Ignore cleanup failure.
    }
  }

  // ============================================================
  // CREATE REMINDER
  // ============================================================

  Future<void> _createReminder() async {
    // ==========================================================
    // PREVENT DOUBLE TAP
    // ==========================================================

    if (_isCreating) {
      return;
    }

    // ==========================================================
    // FORM VALIDATION
    // ==========================================================

    final form =
        _formKey.currentState;

    if (form == null ||
        !form.validate()) {
      return;
    }

    // ==========================================================
    // FUTURE DATE/TIME
    // ==========================================================

    if (!_selectedDateTime.isAfter(
      DateTime.now(),
    )) {
      _showMessage(
        'Please select a future date and time.',
      );
      return;
    }

    // ==========================================================
    // CUSTOM SOUND VALIDATION
    // ==========================================================

    if (_selectedMode ==
            ReminderMode.alarm &&
        _selectedSoundPath != null &&
        _selectedSoundPath!
            .trim()
            .isNotEmpty) {
      final soundFile =
          File(
        _selectedSoundPath!,
      );

      if (!await soundFile.exists()) {
        _showMessage(
          'Selected alarm sound is no longer available.',
        );
        return;
      }

      final size =
          await soundFile.length();

      if (size <= 0) {
        _showMessage(
          'Selected alarm sound is empty.',
        );
        return;
      }
    }

    // ==========================================================
    // START LOADING
    // ==========================================================

    if (mounted) {
      setState(() {
        _isCreating =
            true;
      });
    }

    try {
      final notifier =
          ref.read(
        reminderProvider.notifier,
      );

      // ========================================================
      // ADD REMINDER
      // ========================================================

      await notifier.addReminder(
        plantName:
            _plantController.text.trim(),

        title:
            _titleController.text.trim(),

        description:
            _descriptionController.text.trim(),

        type:
            _selectedType,

        scheduledAt:
            _selectedDateTime,

        mode:
            _selectedMode,

        // ======================================================
        // ALARM
        //
        // null = device default alarm sound.
        // custom path = selected music.
        // ======================================================

        soundPath:
            _selectedMode ==
                    ReminderMode.alarm
                ? _selectedSoundPath
                : null,

        soundName:
            _selectedMode ==
                    ReminderMode.alarm
                ? _selectedSoundName
                : null,
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // CHECK PROVIDER ERROR
      // ========================================================

      final currentState =
          ref.read(
        reminderProvider,
      );

      if (currentState.errorMessage !=
          null) {
        _showMessage(
          currentState.errorMessage!,
        );
        return;
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      Navigator.of(
        context,
      ).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to create reminder.\n'
        '${_cleanError(e)}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating =
              false;
        });
      }
    }
  }

  // ============================================================
  // FILE EXTENSION
  // ============================================================

  String _fileExtension(
    String fileName,
  ) {
    final index =
        fileName.lastIndexOf('.');

    if (index == -1) {
      return '';
    }

    return fileName
        .substring(index)
        .toLowerCase();
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(
    Object error,
  ) {
    final text =
        error.toString();

    if (text.startsWith(
      'Exception: ',
    )) {
      return text.substring(
        'Exception: '.length,
      );
    }

    return text;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    )
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(
          16,
        ),
      ),
    );
  }

  // ============================================================
  // TYPE LABEL
  // ============================================================

  String _typeLabel(
    ReminderType type,
  ) {
    switch (type) {
      case ReminderType.watering:
        return 'Watering';

      case ReminderType.fertilizing:
        return 'Fertilizing';

      case ReminderType.sunlight:
        return 'Sunlight';

      case ReminderType.treatment:
        return 'Treatment';

      case ReminderType.custom:
        return 'Custom';
    }
  }

  // ============================================================
  // TYPE ICON
  // ============================================================

  IconData _typeIcon(
    ReminderType type,
  ) {
    switch (type) {
      case ReminderType.watering:
        return Icons.water_drop_rounded;

      case ReminderType.fertilizing:
        return Icons.grass_rounded;

      case ReminderType.sunlight:
        return Icons.wb_sunny_rounded;

      case ReminderType.treatment:
        return Icons.medical_services_rounded;

      case ReminderType.custom:
        return Icons.notifications_rounded;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          28,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // TOP HANDLE
              // ==================================================

              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.border,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primary
                              .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .notifications_active_rounded,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Create Reminder',
                          style:
                              AppTextStyles
                                  .heading2,
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),
                        Text(
                          'Never miss an important plant care task.',
                          style:
                              AppTextStyles
                                  .caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    AppSpacing.xl,
              ),

              // ==================================================
              // PLANT
              // ==================================================

              _SectionLabel(
                icon:
                    Icons.local_florist_outlined,
                title:
                    'Plant',
              ),

              const SizedBox(
                height:
                    AppSpacing.sm,
              ),

              TextFormField(
                controller:
                    _plantController,
                textCapitalization:
                    TextCapitalization
                        .words,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Plant Name',
                  hintText:
                      'e.g. Rose',
                  prefixIcon:
                      Icon(
                    Icons
                        .local_florist_outlined,
                  ),
                ),
                validator:
                    (value) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter the plant name';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

              // ==================================================
              // TYPE
              // ==================================================

              _SectionLabel(
                icon:
                    Icons.category_outlined,
                title:
                    'Reminder Type',
              ),

              const SizedBox(
                height:
                    AppSpacing.sm,
              ),

              DropdownButtonFormField<
                  ReminderType>(
                initialValue:
                    _selectedType,
                decoration:
                    const InputDecoration(
                  prefixIcon:
                      Icon(
                    Icons
                        .category_outlined,
                  ),
                ),
                items:
                    ReminderType.values
                        .map(
                  (
                    type,
                  ) {
                    return DropdownMenuItem<
                        ReminderType>(
                      value:
                          type,
                      child:
                          Row(
                        children: [
                          Icon(
                            _typeIcon(
                              type,
                            ),
                            size:
                                20,
                            color:
                                AppColors
                                    .primary,
                          ),
                          const SizedBox(
                            width:
                                AppSpacing.sm,
                          ),
                          Text(
                            _typeLabel(
                              type,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
                onChanged:
                    (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    _selectedType =
                        value;
                  });
                },
              ),

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

              // ==================================================
              // DETAILS
              // ==================================================

              _SectionLabel(
                icon:
                    Icons.title_rounded,
                title:
                    'Reminder Details',
              ),

              const SizedBox(
                height:
                    AppSpacing.sm,
              ),

              TextFormField(
                controller:
                    _titleController,
                textCapitalization:
                    TextCapitalization
                        .sentences,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Reminder Title',
                  hintText:
                      'e.g. Water the rose',
                  prefixIcon:
                      Icon(
                    Icons.title_rounded,
                  ),
                ),
                validator:
                    (value) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter a reminder title';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height:
                    AppSpacing.md,
              ),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 3,
                textCapitalization:
                    TextCapitalization
                        .sentences,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Description',
                  hintText:
                      'Add some details...',
                  prefixIcon:
                      Icon(
                    Icons.notes_rounded,
                  ),
                  alignLabelWithHint:
                      true,
                ),
              ),

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

              // ==================================================
              // SCHEDULE
              // ==================================================

              _SectionLabel(
                icon:
                    Icons.schedule_rounded,
                title:
                    'Schedule',
              ),

              const SizedBox(
                height:
                    AppSpacing.sm,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _ScheduleButton(
                      icon:
                          Icons
                              .calendar_today_rounded,
                      label:
                          '${_selectedDateTime.day.toString().padLeft(2, '0')}/'
                          '${_selectedDateTime.month.toString().padLeft(2, '0')}/'
                          '${_selectedDateTime.year}',
                      onPressed:
                          _selectDate,
                    ),
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.sm,
                  ),

                  Expanded(
                    child:
                        _ScheduleButton(
                      icon:
                          Icons
                              .access_time_rounded,
                      label:
                          TimeOfDay
                              .fromDateTime(
                        _selectedDateTime,
                      ).format(
                        context,
                      ),
                      onPressed:
                          _selectTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

              // ==================================================
              // MODE
              // ==================================================

              _SectionLabel(
                icon:
                    Icons
                        .notifications_active_outlined,
                title:
                    'Reminder Mode',
              ),

              const SizedBox(
                height:
                    AppSpacing.xs,
              ),

              Text(
                'Choose how GreenMind should remind you.',
                style:
                    AppTextStyles.caption,
              ),

              const SizedBox(
                height:
                    AppSpacing.sm,
              ),

              _ReminderModeSelector(
                selectedMode:
                    _selectedMode,
                onChanged:
                    (mode) {
                  setState(() {
                    _selectedMode =
                        mode;
                  });

                  // Notification mode does not use
                  // custom alarm sound.
                  if (mode ==
                      ReminderMode
                          .notification) {
                    _removeSound();
                  }
                },
              ),

              // ==================================================
              // ALARM SETTINGS
              // ==================================================

              if (_selectedMode ==
                  ReminderMode.alarm) ...[
                const SizedBox(
                  height:
                      AppSpacing.lg,
                ),

                _SectionLabel(
                  icon:
                      Icons.alarm_rounded,
                  title:
                      'Alarm Sound',
                ),

                const SizedBox(
                  height:
                      AppSpacing.xs,
                ),

                Text(
                  'Use the default alarm sound or choose music from your phone.',
                  style:
                      AppTextStyles.caption,
                ),

                const SizedBox(
                  height:
                      AppSpacing.sm,
                ),

                _AlarmSoundSelector(
                  soundName:
                      _selectedSoundName,
                  isSelecting:
                      _isSelectingSound,
                  onDefault:
                      _useDefaultAlarm,
                  onPick:
                      _pickSound,
                  onRemove:
                      _removeSound,
                ),
              ],

              const SizedBox(
                height:
                    AppSpacing.xl,
              ),

              // ==================================================
              // CREATE
              // ==================================================

              SizedBox(
                width:
                    double.infinity,
                height:
                    56,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _isCreating
                          ? null
                          : _createReminder,
                  icon:
                      _isCreating
                          ? const SizedBox(
                              width:
                                  21,
                              height:
                                  21,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : Icon(
                              _selectedMode ==
                                      ReminderMode
                                          .alarm
                                  ? Icons
                                      .alarm_add_rounded
                                  : Icons
                                      .add_alert_rounded,
                            ),
                  label:
                      Text(
                    _isCreating
                        ? 'Creating...'
                        : _selectedMode ==
                                ReminderMode
                                    .alarm
                            ? 'Create Alarm'
                            : 'Create Reminder',
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        AppColors
                            .primary,
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        AppColors
                            .primary
                            .withValues(
                      alpha:
                          0.45,
                    ),
                    disabledForegroundColor:
                        Colors.white,
                    elevation:
                        0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        AppRadius.card,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    AppSpacing.sm,
              ),

              Center(
                child:
                    Text(
                  _selectedMode ==
                          ReminderMode
                              .alarm
                      ? 'Alarm will ring at the selected time.'
                      : 'You will receive a notification at the selected time.',
                  textAlign:
                      TextAlign.center,
                  style:
                      AppTextStyles.caption,
                ),
              ),

              const SizedBox(
                height:
                    AppSpacing.md,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION LABEL
// ============================================================

class _SectionLabel
    extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color:
              AppColors.primary,
        ),
        const SizedBox(
          width: 7,
        ),
        Text(
          title,
          style:
              AppTextStyles.title,
        ),
      ],
    );
  }
}

// ============================================================
// SCHEDULE BUTTON
// ============================================================

class _ScheduleButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ScheduleButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return OutlinedButton.icon(
      onPressed:
          onPressed,
      icon:
          Icon(
        icon,
        size: 18,
      ),
      label:
          Text(
        label,
        overflow:
            TextOverflow.ellipsis,
      ),
      style:
          OutlinedButton
              .styleFrom(
        minimumSize:
            const Size(
          0,
          52,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        side:
            const BorderSide(
          color:
              AppColors.border,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.card,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REMINDER MODE SELECTOR
// ============================================================

class _ReminderModeSelector
    extends StatelessWidget {
  final ReminderMode selectedMode;

  final ValueChanged<
      ReminderMode> onChanged;

  const _ReminderModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        4,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child:
          Row(
        children: [
          Expanded(
            child:
                _ModeOption(
              icon:
                  Icons
                      .notifications_active_outlined,
              label:
                  'Notification',
              subtitle:
                  'Quiet reminder',
              selected:
                  selectedMode ==
                      ReminderMode
                          .notification,
              onTap:
                  () => onChanged(
                ReminderMode
                    .notification,
              ),
            ),
          ),
          Expanded(
            child:
                _ModeOption(
              icon:
                  Icons
                      .alarm_rounded,
              label:
                  'Alarm',
              subtitle:
                  'Sound + vibration',
              selected:
                  selectedMode ==
                      ReminderMode
                          .alarm,
              onTap:
                  () => onChanged(
                ReminderMode
                    .alarm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODE OPTION
// ============================================================

class _ModeOption
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          selected
              ? AppColors.primary
              : Colors.transparent,
      borderRadius:
          BorderRadius.circular(
        AppRadius.card,
      ),
      child:
          InkWell(
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        child:
            Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ),
          child:
              Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    selected
                        ? Colors.white
                        : AppColors
                            .textSecondary,
              ),
              const SizedBox(
                width: 7,
              ),
              Flexible(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      label,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            selected
                                ? Colors
                                    .white
                                : AppColors
                                    .textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      subtitle,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        fontSize: 10,
                        color:
                            selected
                                ? Colors
                                    .white
                                    .withValues(
                                    alpha:
                                        0.82,
                                  )
                                : AppColors
                                    .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ALARM SOUND SELECTOR
// ============================================================

class _AlarmSoundSelector
    extends StatelessWidget {
  final String? soundName;

  final bool isSelecting;

  final VoidCallback onDefault;

  final VoidCallback onPick;

  final VoidCallback onRemove;

  const _AlarmSoundSelector({
    required this.soundName,
    required this.isSelecting,
    required this.onDefault,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final hasCustomSound =
        soundName != null &&
            soundName!
                .trim()
                .isNotEmpty;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child:
          Column(
        children: [
          // ======================================================
          // DEFAULT ALARM
          // ======================================================

          InkWell(
            onTap:
                onDefault,
            borderRadius:
                BorderRadius.circular(
              AppRadius.card,
            ),
            child:
                Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    !hasCustomSound
                        ? AppColors
                            .primary
                            .withValues(
                            alpha:
                                0.08,
                          )
                        : Colors
                            .transparent,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                border:
                    Border.all(
                  color:
                      !hasCustomSound
                          ? AppColors
                              .primary
                              .withValues(
                              alpha:
                                  0.35,
                            )
                          : AppColors
                              .border,
                ),
              ),
              child:
                  Row(
                children: [
                  Container(
                    width:
                        44,
                    height:
                        44,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primary
                              .withValues(
                        alpha:
                            0.10,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .notifications_active_rounded,
                      color:
                          AppColors
                              .primary,
                    ),
                  ),
                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),
                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Default Alarm',
                          style:
                              AppTextStyles
                                  .title,
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Use the phone\'s default alarm sound',
                          style:
                              AppTextStyles
                                  .caption,
                        ),
                      ],
                    ),
                  ),
                  if (!hasCustomSound)
                    const Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                          AppColors
                              .primary,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height:
                AppSpacing.sm,
          ),

          // ======================================================
          // CUSTOM MUSIC
          // ======================================================

          if (hasCustomSound)
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha:
                      0.06,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child:
                  Row(
                children: [
                  const Icon(
                    Icons
                        .music_note_rounded,
                    color:
                        AppColors
                            .primary,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Custom Music',
                          style:
                              AppTextStyles
                                  .title,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          soundName!,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              AppTextStyles
                                  .caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        onRemove,
                    tooltip:
                        'Remove music',
                    icon:
                        const Icon(
                      Icons
                          .close_rounded,
                    ),
                  ),
                ],
              ),
            ),

          if (hasCustomSound)
            const SizedBox(
              height:
                  AppSpacing.sm,
            ),

          // ======================================================
          // CHOOSE MUSIC
          // ======================================================

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton.icon(
              onPressed:
                  isSelecting
                      ? null
                      : onPick,
              icon:
                  isSelecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons
                              .library_music_rounded,
                        ),
              label:
                  Text(
                isSelecting
                    ? 'Selecting Music...'
                    : 'Choose Music from Phone',
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'Supported: MP3, WAV, M4A, AAC, OGG',
            textAlign:
                TextAlign.center,
            style:
                AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}