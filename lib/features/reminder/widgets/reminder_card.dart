import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/plant_reminder.dart';
import '../providers/reminder_provider.dart';

class ReminderCard extends ConsumerWidget {
  final PlantReminder reminder;

  const ReminderCard({
    super.key,
    required this.reminder,
  });

  IconData _getIcon() {
    switch (reminder.type) {
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

  Color _getColor() {
    switch (reminder.type) {
      case ReminderType.watering:
        return Colors.blue;
      case ReminderType.fertilizing:
        return Colors.green;
      case ReminderType.sunlight:
        return Colors.orange;
      case ReminderType.treatment:
        return AppColors.error;
      case ReminderType.custom:
        return AppColors.primary;
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final color = _getColor();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: reminder.isCompleted ? 0.55 : 1.0,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: AppSpacing.md,
        ),
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.card,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                _getIcon(),
                color: color,
              ),
            ),

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style:
                        AppTextStyles.title.copyWith(
                      decoration:
                          reminder.isCompleted
                              ? TextDecoration
                                  .lineThrough
                              : null,
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  Text(
                    reminder.plantName,
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  if (reminder.description
                      .trim()
                      .isNotEmpty)
                    Text(
                      reminder.description,
                      style:
                          AppTextStyles.caption,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color:
                            AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(
                            reminder.scheduledAt,
                          ),
                          style:
                              AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  Row(
                    children: [
                      Icon(
                        reminder.isAlarm
                            ? Icons.alarm_rounded
                            : Icons
                                .notifications_none_rounded,
                        size: 15,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.modeLabel,
                        style:
                            AppTextStyles.caption
                                .copyWith(
                          color: color,
                        ),
                      ),

                      if (reminder.hasCustomSound) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.music_note_rounded,
                          size: 15,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            reminder.soundName ??
                                'Custom sound',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) async {
                final notifier = ref.read(
                  reminderProvider.notifier,
                );

                if (value == 'complete') {
                  await notifier.toggleCompleted(
                    reminder.id,
                  );
                }

                if (value == 'delete') {
                  await notifier.deleteReminder(
                    reminder.id,
                  );
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'complete',
                    child: Text(
                      reminder.isCompleted
                          ? 'Mark as Pending'
                          : 'Mark as Complete',
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}