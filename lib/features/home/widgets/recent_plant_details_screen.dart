import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../models/recent_plant.dart';

class RecentPlantDetailsScreen
    extends StatelessWidget {
  final RecentPlant plant;

  const RecentPlantDetailsScreen({
    super.key,
    required this.plant,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final confidence =
        plant.confidence
            .clamp(
              0.0,
              100.0,
            )
            .toDouble();

    final isDisease =
        plant.isDiseaseDetection;

    final title = isDisease
        ? (
            plant.diseaseName
                    .trim()
                    .isEmpty
                ? 'Plant Health Scan'
                : plant.diseaseName.trim()
          )
        : (
            plant.plantName
                    .trim()
                    .isEmpty
                ? 'Unknown Plant'
                : plant.plantName.trim()
          );

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          isDisease
              ? 'Health Scan Details'
              : 'Plant Details',
        ),
        backgroundColor:
            theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor:
            theme.colorScheme.onSurface,
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            _PlantDetailsImage(
              imageBase64:
                  plant.imageBase64,
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // SCAN TYPE
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    isDisease
                        ? Icons
                            .health_and_safety_rounded
                        : Icons
                            .local_florist_rounded,
                    size: 17,
                    color:
                        AppColors.primary,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    isDisease
                        ? 'Disease Detection'
                        : 'Plant Identification',
                    style:
                        AppTextStyles
                            .caption
                            .copyWith(
                      color:
                          AppColors.primary,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // TITLE
            // ==================================================

            Text(
              title,
              style:
                  AppTextStyles.heading1,
            ),

            // ==================================================
            // SCIENTIFIC NAME
            // ==================================================

            if (!isDisease &&
                plant.scientificName
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(
                height: 6,
              ),
              Text(
                plant.scientificName.trim(),
                style:
                    AppTextStyles.body
                        .copyWith(
                  fontStyle:
                      FontStyle.italic,
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
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: 8,
            ),

            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                    child:
                        LinearProgressIndicator(
                      value:
                          confidence / 100,
                      minHeight: 10,
                      backgroundColor:
                          AppColors.primary
                              .withValues(
                        alpha: 0.10,
                      ),
                      color:
                          AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Text(
                  '${confidence.toStringAsFixed(0)}%',
                  style:
                      AppTextStyles.body
                          .copyWith(
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.primary,
                  ),
                ),
              ],
            ),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            if (plant.description
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 28,
              ),
              _Section(
                icon:
                    Icons.info_outline_rounded,
                title:
                    'Description',
                child:
                    Text(
                  plant.description,
                  style:
                      AppTextStyles.body,
                ),
              ),
            ],

            // ==================================================
            // DISEASE DETAILS
            // ==================================================

            if (isDisease) ...[
              if (plant.symptoms
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 28,
                ),
                _Section(
                  icon:
                      Icons.visibility_outlined,
                  title:
                      'Symptoms',
                  child:
                      Text(
                    plant.symptoms,
                    style:
                        AppTextStyles.body,
                  ),
                ),
              ],

              if (plant.treatment
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 28,
                ),
                _Section(
                  icon:
                      Icons
                          .medical_services_outlined,
                  title:
                      'Treatment',
                  child:
                      Text(
                    plant.treatment,
                    style:
                        AppTextStyles.body,
                  ),
                ),
              ],

              if (plant.prevention
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 28,
                ),
                _Section(
                  icon:
                      Icons.shield_outlined,
                  title:
                      'Prevention',
                  child:
                      Text(
                    plant.prevention,
                    style:
                        AppTextStyles.body,
                  ),
                ),
              ],
            ],

            // ==================================================
            // CARE TIPS
            // ==================================================

            if (plant.careTips
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 28,
              ),

              _Section(
                icon:
                    Icons.eco_outlined,
                title:
                    isDisease
                        ? 'Care & Management'
                        : 'Care Tips',
                child:
                    Text(
                  plant.careTips,
                  style:
                      AppTextStyles.body,
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
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                AppSpacing.md,
              ),
              decoration:
                  BoxDecoration(
                color:
                    plant.isHealthy
                        ? Colors.green
                            .withValues(
                            alpha: 0.08,
                          )
                        : Colors.orange
                            .withValues(
                            alpha: 0.08,
                          ),
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.card,
                ),
                border:
                    Border.all(
                  color:
                      plant.isHealthy
                          ? Colors.green
                              .withValues(
                              alpha: 0.18,
                            )
                          : Colors.orange
                              .withValues(
                              alpha: 0.18,
                            ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    plant.isHealthy
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .warning_amber_rounded,
                    color:
                        plant.isHealthy
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
                      style:
                          AppTextStyles.body
                              .copyWith(
                        fontWeight:
                            FontWeight.w600,
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
// IMAGE
// ============================================================

class _PlantDetailsImage
    extends StatelessWidget {
  final String? imageBase64;

  const _PlantDetailsImage({
    required this.imageBase64,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final value =
        imageBase64?.trim();

    if (value == null ||
        value.isEmpty) {
      return _placeholder();
    }

    try {
      final bytes =
          base64Decode(value);

      if (bytes.isEmpty) {
        return _placeholder();
      }

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child: Image.memory(
          bytes,
          width:
              double.infinity,
          height: 280,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder:
              (
            context,
            error,
            stackTrace,
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
      width:
          double.infinity,
      height: 280,
      decoration:
          BoxDecoration(
        color:
            AppColors.primary
                .withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: const Icon(
        Icons.local_florist_rounded,
        size: 80,
        color:
            AppColors.primary,
      ),
    );
  }
}

// ============================================================
// SECTION
// ============================================================

class _Section
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 21,
              color:
                  AppColors.primary,
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Text(
              title,
              style:
                  AppTextStyles.heading3,
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