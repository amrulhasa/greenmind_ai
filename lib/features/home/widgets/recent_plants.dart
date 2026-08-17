import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../models/recent_plant.dart';
import '../providers/recent_plants_provider.dart';
import 'recent_plant_details_screen.dart';

class RecentPlants extends ConsumerWidget {
  const RecentPlants({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state =
        ref.watch(recentPlantsProvider);

    // ==========================================================
    // LOADING
    // ==========================================================

    if (state.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (state.errorMessage != null &&
        state.plants.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.red.withValues(
            alpha: 0.06,
          ),
          borderRadius:
              BorderRadius.circular(
            AppRadius.card,
          ),
        ),
        child: Text(
          state.errorMessage!,
          style:
              AppTextStyles.body.copyWith(
            color: Colors.red,
          ),
        ),
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (state.plants.isEmpty) {
      return const SizedBox.shrink();
    }

    // ==========================================================
    // RECENT SCANS
    // ==========================================================

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ========================================================
        // HEADER
        // ========================================================

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Scans',
              style:
                  AppTextStyles.heading2,
            ),

            TextButton(
              onPressed: () async {
                await ref
                    .read(
                      recentPlantsProvider
                          .notifier,
                    )
                    .clearAll();
              },
              child:
                  const Text('Clear'),
            ),
          ],
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        // ========================================================
        // LIST
        // ========================================================

        ListView.separated(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              state.plants.length,
          separatorBuilder:
              // ignore: unnecessary_underscores
              (_, __) {
            return const SizedBox(
              height: AppSpacing.sm,
            );
          },
          itemBuilder:
              (context, index) {
            final plant =
                state.plants[index];

            return _RecentPlantCard(
              plant: plant,
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// RECENT CARD
// ============================================================

class _RecentPlantCard
    extends StatelessWidget {
  final RecentPlant plant;

  const _RecentPlantCard({
    required this.plant,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final confidence =
        plant.confidence.clamp(
      0.0,
      100.0,
    );

    final bool isDisease =
        plant.isDiseaseDetection;

    return Material(
      color: Colors.transparent,
      borderRadius:
          BorderRadius.circular(
        AppRadius.card,
      ),
      clipBehavior:
          Clip.antiAlias,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  RecentPlantDetailsScreen(
                plant: plant,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
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
            boxShadow:
                const [
              BoxShadow(
                color:
                    AppColors.shadow,
                blurRadius: 12,
                offset:
                    Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              _PlantImage(
                imageBase64:
                    plant.imageBase64,
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              // ==================================================
              // INFORMATION
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDisease
                          ? (plant.diseaseName
                                  .isEmpty
                              ? 'Plant Health Scan'
                              : plant.diseaseName)
                          : (plant.plantName
                                  .isEmpty
                              ? 'Unknown Plant'
                              : plant.plantName),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles.heading3,
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    // Scan type
                    Text(
                      isDisease
                          ? 'Disease Detection'
                          : 'Plant Identification',
                      style:
                          AppTextStyles.caption
                              .copyWith(
                        color:
                            AppColors.primary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    if (!isDisease &&
                        plant
                            .scientificName
                            .isNotEmpty) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        plant.scientificName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles.caption
                                .copyWith(
                          fontStyle:
                              FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .verified_outlined,
                          size: 16,
                          color:
                              AppColors.primary,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          '${confidence.toStringAsFixed(0)}% confidence',
                          style:
                              AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              // ==================================================
              // HEALTH
              // ==================================================

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
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// IMAGE
// ============================================================

class _PlantImage
    extends StatelessWidget {
  final String? imageBase64;

  const _PlantImage({
    required this.imageBase64,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (imageBase64 == null ||
        imageBase64!.isEmpty) {
      return _placeholder();
    }

    try {
      final bytes =
          base64Decode(
        imageBase64!,
      );

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(16),
        child: Image.memory(
          bytes,
          width: 72,
          height: 72,
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
      width: 72,
      height: 72,
      decoration:
          BoxDecoration(
        color:
            AppColors.primary
                .withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: const Icon(
        Icons
            .local_florist_rounded,
        color:
            AppColors.primary,
        size: 32,
      ),
    );
  }
}