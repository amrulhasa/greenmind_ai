import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/disease_provider.dart';

class DetectButton extends ConsumerWidget {
  const DetectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diseaseProvider);
    final notifier = ref.read(diseaseProvider.notifier);

    final bool hasImage = state.imageBytes != null;
    final bool isLoading = state.isLoading;
    final bool isDisabled = !hasImage || isLoading;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () async {
                await notifier.detectDisease();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.80),
          elevation: isDisabled ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading ? const _LoadingContent() : const _ReadyContent(),
        ),
      ),
    );
  }
}

// ==========================================
// READY CONTENT
// ==========================================

class _ReadyContent extends StatelessWidget {
  const _ReadyContent();

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: ValueKey('ready'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.health_and_safety_outlined, size: 23),
        SizedBox(width: AppSpacing.sm),
        Text('Detect Disease'),
      ],
    );
  }
}

// ==========================================
// LOADING CONTENT
// ==========================================

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text('Analyzing...'),
      ],
    );
  }
}
