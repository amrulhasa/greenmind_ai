import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/identify_result.dart';

class IdentifyResultCard extends StatelessWidget {
  final IdentifyResult result;

  final VoidCallback? onGenerateReport;

  const IdentifyResultCard({
    super.key,
    required this.result,
    this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = result.confidence.clamp(
      0.0,
      100.0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: Text(
                  'Identification Result',
                  style: AppTextStyles.heading3,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          // ======================================================
          // PLANT NAME
          // ======================================================

          Text(
            result.plantName.isEmpty
                ? 'Unknown Plant'
                : result.plantName,
            style: AppTextStyles.heading2,
          ),

          if (result.scientificName.isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(
              result.scientificName,
              style: AppTextStyles.body.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(
            height: AppSpacing.xl,
          ),

          // ======================================================
          // CONFIDENCE
          // ======================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence',
                style: AppTextStyles.heading3,
              ),

              Text(
                '${confidence.toStringAsFixed(0)}%',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(
              10,
            ),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 9,
              backgroundColor:
                  AppColors.primary.withValues(
                alpha: 0.10,
              ),
              color: AppColors.primary,
            ),
          ),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          if (result.description.isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.xl,
            ),

            _Section(
              icon: Icons.info_outline_rounded,
              title: 'Description',
              child: Text(
                result.description,
                style: AppTextStyles.body,
              ),
            ),
          ],

          // ======================================================
          // CARE TIPS
          // ======================================================

          if (result.careTips.isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.xl,
            ),

            _Section(
              icon: Icons.eco_outlined,
              title: 'Care Tips',
              child: Text(
                result.careTips,
                style: AppTextStyles.body,
              ),
            ),
          ],

          const SizedBox(
            height: AppSpacing.xl,
          ),

          // ======================================================
          // HEALTH STATUS
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: result.isHealthy
                  ? Colors.green.withValues(
                      alpha: 0.08,
                    )
                  : Colors.orange.withValues(
                      alpha: 0.08,
                    ),
              borderRadius: BorderRadius.circular(
                AppRadius.card,
              ),
              border: Border.all(
                color: result.isHealthy
                    ? Colors.green.withValues(
                        alpha: 0.18,
                      )
                    : Colors.orange.withValues(
                        alpha: 0.18,
                      ),
              ),
            ),

            child: Row(
              children: [
                Icon(
                  result.isHealthy
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: result.isHealthy
                      ? Colors.green
                      : Colors.orange,
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                Expanded(
                  child: Text(
                    result.isHealthy
                        ? 'Plant appears healthy'
                        : 'Possible health issue detected',
                    style:
                        AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // GENERATE REPORT BUTTON
          // ======================================================

          if (onGenerateReport != null) ...[
            const SizedBox(
              height: AppSpacing.xl,
            ),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onGenerateReport,
                icon: const Icon(
                  Icons.description_outlined,
                ),
                label: const Text(
                  'Generate Plant Care Report',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================================
// SECTION
// ================================================================

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: AppColors.primary,
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Text(
              title,
              style: AppTextStyles.heading3,
            ),
          ],
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        child,
      ],
    );
  }
}