import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/nursery.dart';

class NurseryCard extends StatelessWidget {
  const NurseryCard({
    super.key,
    required this.nursery,
    this.onTap,
  });

  final Nursery nursery;
  final VoidCallback? onTap;

  // ============================================================
  // DIRECTIONS
  // ============================================================

  Future<void> _openDirections() async {
    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination':
            '${nursery.latitude},${nursery.longitude}',
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode:
              LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      // Ignore launcher errors.
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final hasRating =
        nursery.rating != null;

    final hasOpenStatus =
        nursery.isOpen != null;

    return Card(
      elevation: 0,

      margin:
          const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),

      color:
          AppColors.surface,

      clipBehavior:
          Clip.antiAlias,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.circular,
        ),

        side:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),

      child: InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          AppRadius.circular,
        ),

        child: Padding(
          padding:
              const EdgeInsets.all(
            AppSpacing.md,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ------------------------------------------------
                  // ICON
                  // ------------------------------------------------

                  Container(
                    width: 54,
                    height: 54,

                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primary
                              .withValues(
                        alpha: 0.10,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.circular,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .local_florist_rounded,
                      color:
                          AppColors.primary,
                      size: 29,
                    ),
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),

                  // ------------------------------------------------
                  // NAME + ADDRESS
                  // ------------------------------------------------

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          nursery.name,

                          maxLines: 2,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              AppTextStyles.title,
                        ),

                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.only(
                                top: 1,
                              ),

                              child:
                                  Icon(
                                Icons
                                    .location_on_outlined,
                                size: 16,
                                color:
                                    AppColors
                                        .textSecondary,
                              ),
                            ),

                            const SizedBox(
                              width: 4,
                            ),

                            Expanded(
                              child:
                                  Text(
                                nursery.address
                                        .trim()
                                        .isEmpty
                                    ? 'Address unavailable'
                                    : nursery
                                        .address,

                                maxLines: 2,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    AppTextStyles
                                        .caption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    AppSpacing.md,
              ),

              // ==================================================
              // INFO ROW
              // ==================================================

              Wrap(
                spacing:
                    AppSpacing.sm,

                runSpacing:
                    AppSpacing.sm,

                crossAxisAlignment:
                    WrapCrossAlignment
                        .center,

                children: [
                  // Distance
                  _InfoChip(
                    icon:
                        Icons
                            .near_me_rounded,
                    label:
                        nursery
                            .distanceLabel,
                  ),

                  // Rating
                  if (hasRating)
                    _InfoChip(
                      icon:
                          Icons
                              .star_rounded,
                      label:
                          nursery
                              .ratingLabel,
                    ),

                  // Open / Closed
                  if (hasOpenStatus)
                    _StatusChip(
                      isOpen:
                          nursery.isOpen!,
                      label:
                          nursery
                              .openStatusLabel,
                    ),
                ],
              ),

              const SizedBox(
                height:
                    AppSpacing.md,
              ),

              // ==================================================
              // DIRECTIONS
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                child:
                    OutlinedButton.icon(
                  onPressed:
                      _openDirections,

                  icon:
                      const Icon(
                    Icons
                        .directions_rounded,
                  ),

                  label:
                      const Text(
                    'Get Directions',
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColors.primary,

                    side:
                        const BorderSide(
                      color:
                          AppColors.primary,
                    ),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 13,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.circular,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip
    extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 34,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.background,

        borderRadius:
            BorderRadius.circular(
          AppRadius.circular,
        ),
      ),

      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 16,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            label,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OPEN STATUS CHIP
// ============================================================

class _StatusChip
    extends StatelessWidget {
  const _StatusChip({
    required this.isOpen,
    required this.label,
  });

  final bool isOpen;
  final String label;

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        isOpen
            ? AppColors.primary
            : AppColors.error;

    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 34,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.08,
        ),

        borderRadius:
            BorderRadius.circular(
          AppRadius.circular,
        ),
      ),

      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            isOpen
                ? Icons
                    .check_circle_outline_rounded
                : Icons
                    .cancel_outlined,

            size: 16,

            color:
                color,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            label,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style:
                TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
              color:
                  color,
            ),
          ),
        ],
      ),
    );
  }
}