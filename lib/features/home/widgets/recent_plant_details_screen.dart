import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/recent_plant.dart';

class RecentPlantDetailsScreen extends StatelessWidget {
  final RecentPlant plant;

  const RecentPlantDetailsScreen({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final confidence = plant.confidence.clamp(
      0.0,
      100.0,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Plant Details'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // PLANT IMAGE
            // ==================================================

            _PlantDetailsImage(
              imageBase64: plant.imageBase64,
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // PLANT NAME
            // ==================================================

            Text(
              plant.plantName.isEmpty
                  ? 'Unknown Plant'
                  : plant.plantName,
              style: AppTextStyles.heading1,
            ),

            if (plant.scientificName.isNotEmpty) ...[
              const SizedBox(
                height: 6,
              ),

              Text(
                plant.scientificName,
                style: AppTextStyles.body.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // CONFIDENCE
            // ==================================================

            Text(
              'Confidence',
              style: AppTextStyles.heading3,
            ),

            const SizedBox(
              height: 8,
            ),

            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10),

                    child: LinearProgressIndicator(
                      value: confidence / 100,
                      minHeight: 10,
                      backgroundColor:
                          AppColors.primary.withValues(
                        alpha: 0.10,
                      ),
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
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

            // ==================================================
            // DESCRIPTION
            // ==================================================

            if (plant.description.isNotEmpty) ...[
              const SizedBox(
                height: 28,
              ),

              _Section(
                icon: Icons.info_outline_rounded,
                title: 'Description',
                child: Text(
                  plant.description,
                  style: AppTextStyles.body,
                ),
              ),
            ],

            // ==================================================
            // CARE TIPS
            // ==================================================

            if (plant.careTips.isNotEmpty) ...[
              const SizedBox(
                height: 28,
              ),

              _Section(
                icon: Icons.eco_outlined,
                title: 'Care Tips',
                child: Text(
                  plant.careTips,
                  style: AppTextStyles.body,
                ),
              ),
            ],

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // HEALTH STATUS
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),

              decoration: BoxDecoration(
                color: plant.isHealthy
                    ? Colors.green.withValues(
                        alpha: 0.08,
                      )
                    : Colors.orange.withValues(
                        alpha: 0.08,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  AppRadius.card,
                ),

                border: Border.all(
                  color: plant.isHealthy
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
                    plant.isHealthy
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    color: plant.isHealthy
                        ? Colors.green
                        : Colors.orange,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      plant.isHealthy
                          ? 'Plant appears healthy'
                          : 'Possible health issue detected',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PLANT IMAGE
// ============================================================

class _PlantDetailsImage extends StatelessWidget {
  final String? imageBase64;

  const _PlantDetailsImage({
    required this.imageBase64,
  });

  @override
  Widget build(BuildContext context) {
    final encodedImage = imageBase64;

    if (encodedImage == null ||
        encodedImage.isEmpty) {
      return _placeholder();
    }

    try {
      final bytes = base64Decode(
        encodedImage,
      );

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(20),

        child: Image.memory(
          bytes,
          width: double.infinity,
          height: 280,
          fit: BoxFit.cover,

          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return _placeholder();
          },
        ),
      );
    } catch (_) {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 280,

      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Icon(
        Icons.local_florist_rounded,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}

// ============================================================
// SECTION
// ============================================================

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