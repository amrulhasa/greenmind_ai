import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import '../widgets/reminder_empty_state.dart';
import '../widgets/reminder_form.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({
    super.key,
  });

  void _goHome(BuildContext context) {
    context.go('/home');
  }

  Future<void> _openReminderForm(
    BuildContext context,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      useSafeArea: true,
      builder: (_) {
        return const ReminderForm();
      },
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldClear =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Clear all reminders?',
          ),
          content: const Text(
            'All saved reminders will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await ref
          .read(reminderProvider.notifier)
          .clearAllReminders();
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      reminderProvider,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (didPop, result) {
        if (!didPop) {
          _goHome(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _goHome(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),
          title: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Plant Reminders',
                style: AppTextStyles.title,
              ),
              Text(
                'Stay on top of your plant care',
                style:
                    AppTextStyles.caption,
              ),
            ],
          ),
          actions: [
            if (state.reminders.isNotEmpty)
              IconButton(
                tooltip: 'Clear all reminders',
                onPressed: () {
                  _confirmClearAll(
                    context,
                    ref,
                  );
                },
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                ),
              ),
          ],
        ),
        floatingActionButton:
            FloatingActionButton.extended(
          onPressed: () {
            _openReminderForm(context);
          },
          backgroundColor:
              AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(
            Icons.add_alert_rounded,
          ),
          label: const Text(
            'Add Reminder',
          ),
        ),
        body: _buildBody(
          context,
          state,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReminderState state,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: AppColors.error,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                state.errorMessage!,
                style:
                    AppTextStyles.body,
                textAlign:
                    TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.reminders.isEmpty) {
      return const ReminderEmptyState();
    }

    final reminders = [
      ...state.reminders,
    ]..sort(
        (a, b) => a.scheduledAt
            .compareTo(b.scheduledAt),
      );

    return ListView.builder(
      padding:
          const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        100,
      ),
      itemCount: reminders.length,
      itemBuilder: (
        context,
        index,
      ) {
        return ReminderCard(
          reminder: reminders[index],
        );
      },
    );
  }
}