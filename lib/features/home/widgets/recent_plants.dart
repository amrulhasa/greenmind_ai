import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recent_plant.dart';
import '../providers/recent_plants_provider.dart';
import 'recent_plant_details_screen.dart';

class RecentPlants
    extends ConsumerWidget {
  const RecentPlants({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state =
        ref.watch(
      recentPlantsProvider,
    );

    if (state.isLoading) {
      return const _LoadingCard();
    }

    if (state.errorMessage != null &&
        state.plants.isEmpty) {
      return _ErrorCard(
        message:
            state.errorMessage!,
      );
    }

    if (state.plants.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors =
        Theme.of(context)
            .colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color:
                    colors.primary
                        .withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 20,
                color:
                    colors.primary,
              ),
            ),

            const SizedBox(
              width: 11,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Recent Scans',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing:
                          -0.3,
                      color:
                          colors.onSurface,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Your latest plant discoveries',
                    style:
                        TextStyle(
                      fontSize: 11,
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Material(
              color:
                  Colors.transparent,
              child: InkWell(
                onTap: () =>
                    _showClearConfirmation(
                  context,
                  ref,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                child:
                    Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child:
                      Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .delete_outline_rounded,
                        size: 16,
                        color:
                            colors.primary,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Clear',
                        style:
                            TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 15,
        ),

        ListView.separated(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              state.plants.length,
          separatorBuilder:
              (_, _) =>
                  const SizedBox(
            height: 10,
          ),
          itemBuilder:
              (context, index) {
            return _RecentPlantCard(
              plant:
                  state.plants[index],
            );
          },
        ),
      ],
    );
  }

  Future<void>
      _showClearConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final colors =
        Theme.of(context)
            .colorScheme;

    final shouldClear =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons
                    .delete_sweep_outlined,
                color:
                    Color(0xFFD94B43),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  'Clear Recent Scans?',
                  style:
                      TextStyle(
                    color:
                        colors.onSurface,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content:
              Text(
            'All recent plant scans will be removed. '
            'This action cannot be undone.',
            style:
                TextStyle(
              color: colors
                  .onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                context,
              ).pop(false),
              child:
                  const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFD94B43,
                ),
              ),
              onPressed: () =>
                  Navigator.of(
                context,
              ).pop(true),
              child:
                  const Text(
                'Clear Scans',
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    await ref
        .read(
          recentPlantsProvider
              .notifier,
        )
        .clearAll();
  }
}

// ============================================================================
// CARD
// ============================================================================

class _RecentPlantCard
    extends StatelessWidget {
  const _RecentPlantCard({
    required this.plant,
  });

  final RecentPlant plant;

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    final confidence =
        plant.confidence
            .clamp(0.0, 100.0)
            .toDouble();

    final isDisease =
        plant.isDiseaseDetection;

    final title = isDisease
        ? plant.diseaseName
                .trim()
                .isEmpty
            ? 'Plant Health Scan'
            : plant.diseaseName.trim()
        : plant.plantName
                .trim()
                .isEmpty
            ? 'Unknown Plant'
            : plant.plantName.trim();

    final statusColor =
        plant.isHealthy
            ? colors.primary
            : const Color(0xFFE67E22);

    final statusBackground =
        plant.isHealthy
            ? colors.primary
                .withValues(
                alpha: 0.12,
              )
            : const Color(
                0xFFE67E22,
              ).withValues(
                alpha: 0.12,
              );

    return Material(
      color:
          Colors.transparent,
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      clipBehavior:
          Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(
            MaterialPageRoute(
              builder: (_) =>
                  RecentPlantDetailsScreen(
                plant: plant,
              ),
            ),
          );
        },
        child: Ink(
          padding:
              const EdgeInsets.all(
            13,
          ),
          decoration:
              BoxDecoration(
            color:
                colors.surface,
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border:
                Border.all(
              color:
                  colors.outline,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withValues(
                  alpha:
                      Theme.of(context)
                              .brightness ==
                          Brightness.dark
                      ? 0.20
                      : 0.035,
                ),
                blurRadius:
                    19,
                offset:
                    const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              _PlantImage(
                imageBase64:
                    plant.imageBase64,
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              fontSize:
                                  14.5,
                              height:
                                  1.2,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  colors
                                      .onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Container(
                          width: 28,
                          height: 28,
                          decoration:
                              BoxDecoration(
                            color:
                                statusBackground,
                            shape:
                                BoxShape
                                    .circle,
                          ),
                          child:
                              Icon(
                            plant
                                    .isHealthy
                                ? Icons
                                    .check_circle_rounded
                                : Icons
                                    .warning_amber_rounded,
                            size: 16,
                            color:
                                statusColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: isDisease
                            ? const Color(
                                0xFFD94B43,
                              ).withValues(
                                alpha:
                                    0.12,
                              )
                            : colors.primary
                                .withValues(
                                alpha:
                                    0.12,
                              ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child:
                          Text(
                        isDisease
                            ? 'Disease Detection'
                            : 'Plant Identification',
                        style:
                            TextStyle(
                          fontSize:
                              9.5,
                          fontWeight:
                              FontWeight
                                  .w700,
                          color:
                              isDisease
                                  ? const Color(
                                      0xFFFF8178,
                                    )
                                  : colors
                                      .primary,
                        ),
                      ),
                    ),

                    if (!isDisease &&
                        plant
                            .scientificName
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        plant
                            .scientificName
                            .trim(),
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          fontSize:
                              10.5,
                          fontStyle:
                              FontStyle
                                  .italic,
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 7,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .verified_rounded,
                          size: 14,
                          color:
                              colors.primary,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${confidence.toStringAsFixed(0)}% confidence',
                          style:
                              TextStyle(
                            fontSize:
                                10.5,
                            fontWeight:
                                FontWeight
                                    .w600,
                            color: colors
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              Container(
                width: 31,
                height: 31,
                decoration:
                    BoxDecoration(
                  color: colors
                      .surfaceContainerHighest,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    Icon(
                  Icons
                      .chevron_right_rounded,
                  size: 19,
                  color: colors
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// IMAGE
// ============================================================================

class _PlantImage
    extends StatelessWidget {
  const _PlantImage({
    required this.imageBase64,
  });

  final String? imageBase64;

  @override
  Widget build(
    BuildContext context,
  ) {
    final value =
        imageBase64?.trim();

    if (value == null ||
        value.isEmpty) {
      return _placeholder(
        context,
      );
    }

    try {
      var decoded =
          value;

      if (decoded.contains(',')) {
        decoded =
            decoded.split(',').last;
      }

      final bytes =
          base64Decode(decoded);

      if (bytes.isEmpty) {
        return _placeholder(
          context,
        );
      }

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        child: Image.memory(
          bytes,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder:
              (
            context,
            error,
            stackTrace,
          ) =>
                  _placeholder(
            context,
          ),
        ),
      );
    } catch (_) {
      return _placeholder(
        context,
      );
    }
  }

  Widget _placeholder(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      width: 76,
      height: 76,
      decoration:
          BoxDecoration(
        color:
            colors.primary
                .withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border:
            Border.all(
          color:
              colors.outline,
        ),
      ),
      child:
          Icon(
        Icons
            .local_florist_rounded,
        color:
            colors.primary,
        size: 31,
      ),
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _LoadingCard
    extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      height: 150,
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            colors.surface,
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border:
            Border.all(
          color:
              colors.outline,
        ),
      ),
      child:
          Center(
        child:
            SizedBox(
          width: 25,
          height: 25,
          child:
              CircularProgressIndicator(
            strokeWidth: 2.5,
            color:
                colors.primary,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorCard
    extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .error
                .withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              Theme.of(context)
                  .colorScheme
                  .error
                  .withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons
                .error_outline_rounded,
            color:
                Theme.of(context)
                    .colorScheme
                    .error,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              message,
              style:
                  TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}