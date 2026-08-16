import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/plant_reminder.dart';
import '../providers/reminder_provider.dart';

class ReminderForm extends ConsumerStatefulWidget {
  const ReminderForm({super.key});

  @override
  ConsumerState<ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends ConsumerState<ReminderForm> {
  final _formKey = GlobalKey<FormState>();

  final _plantController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReminderType _selectedType = ReminderType.watering;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _plantController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(reminderProvider.notifier);

    await notifier.addReminder(
      plantName: _plantController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      scheduledAt: _selectedDateTime,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  String _typeLabel(ReminderType type) {
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

  IconData _typeIcon(ReminderType type) {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Reminder', style: AppTextStyles.heading2),

            const SizedBox(height: AppSpacing.lg),

            TextFormField(
              controller: _plantController,
              decoration: const InputDecoration(
                labelText: 'Plant Name',
                hintText: 'e.g. Rose',
                prefixIcon: Icon(Icons.local_florist_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the plant name';
                }

                return null;
              },
            ),

            const SizedBox(height: AppSpacing.md),

            Text('Reminder Type', style: AppTextStyles.title),

            const SizedBox(height: AppSpacing.sm),

            DropdownButtonFormField<ReminderType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ReminderType.values.map((type) {
                return DropdownMenuItem<ReminderType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_typeIcon(type), size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(_typeLabel(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedType = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                hintText: 'e.g. Water the rose',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a reminder title';
                }

                return null;
              },
            ),

            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Add some details...',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text('Schedule', style: AppTextStyles.title),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: Text(
                      '${_selectedDateTime.day.toString().padLeft(2, '0')}/'
                      '${_selectedDateTime.month.toString().padLeft(2, '0')}/'
                      '${_selectedDateTime.year}',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time_rounded),
                    label: Text(
                      TimeOfDay.fromDateTime(_selectedDateTime).format(context),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _createReminder,
                icon: const Icon(Icons.add_alert_rounded),
                label: const Text('Create Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
