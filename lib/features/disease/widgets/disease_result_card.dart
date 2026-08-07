import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/disease_provider.dart';

class DiseaseResultCard extends ConsumerWidget {
  const DiseaseResultCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(diseaseProvider).result;

    if (result == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.diseaseName,
            style: AppTextStyles.heading2,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Confidence: ${result.confidence.toStringAsFixed(1)}%',
            style: AppTextStyles.body,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            result.description,
            style: AppTextStyles.body,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Treatment',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            result.treatment,
            style: AppTextStyles.body,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Prevention',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            result.prevention,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}