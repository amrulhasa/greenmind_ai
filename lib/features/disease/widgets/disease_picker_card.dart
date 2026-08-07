import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/disease_provider.dart';

class DiseasePickerCard extends ConsumerWidget {
  const DiseasePickerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(diseaseProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            size: 70,
            color: AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            'Upload Leaf Image',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Take a clear photo of a plant leaf or choose one from your gallery.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: notifier.pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: notifier.pickFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}