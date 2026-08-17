import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/nursery.dart';

class NurseryBottomSheet
    extends StatelessWidget {
  const NurseryBottomSheet({
    super.key,
    required this.nursery,
  });

  final Nursery nursery;

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
  // PHONE
  // ============================================================

  Future<void> _callNursery() async {
    final phone =
        nursery.phoneNumber;

    if (phone == null ||
        phone.trim().isEmpty) {
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: phone.trim(),
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      // Ignore launcher errors.
    }
  }

  // ============================================================
  // WEBSITE
  // ============================================================

  Future<void> _openWebsite() async {
    final website =
        nursery.website;

    if (website == null ||
        website.trim().isEmpty) {
      return;
    }

    var normalized =
        website.trim();

    if (!normalized.startsWith(
          'http://',
        ) &&
        !normalized.startsWith(
          'https://',
        )) {
      normalized =
          'https://$normalized';
    }

    final uri =
        Uri.tryParse(normalized);

    if (uri == null) {
      return;
    }

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
    final hasPhone =
        nursery.phoneNumber != null &&
        nursery.phoneNumber!
            .trim()
            .isNotEmpty;

    final hasWebsite =
        nursery.website != null &&
        nursery.website!
            .trim()
            .isNotEmpty;

    final hasRating =
        nursery.rating != null;

    final hasOpenStatus =
        nursery.isOpen != null;

    final hasPlaceType =
        nursery.placeType != null &&
        nursery.placeType!
            .trim()
            .isNotEmpty;

    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),

        child:
            SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HANDLE
              // ==================================================

              Center(
                child: Container(
                  width: 42,
                  height: 4,

                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.border,

                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.circular,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

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
                    width: 58,
                    height: 58,

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
                      size: 31,
                    ),
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),

                  // ------------------------------------------------
                  // NAME + DISTANCE
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
                          children: [
                            const Icon(
                              Icons
                                  .near_me_rounded,
                              size: 16,
                              color:
                                  AppColors.primary,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              nursery
                                  .distanceLabel,

                              style:
                                  AppTextStyles
                                      .caption
                                      .copyWith(
                                color:
                                    AppColors
                                        .primary,
                                fontWeight:
                                    FontWeight.w600,
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
                    AppSpacing.lg,
              ),

              // ==================================================
              // DETAILS
              // ==================================================

              _DetailRow(
                icon:
                    Icons
                        .location_on_outlined,

                text:
                    nursery.address
                            .trim()
                            .isEmpty
                        ? 'Address unavailable'
                        : nursery.address,
              ),

              // Rating
              if (hasRating)
                _DetailRow(
                  icon:
                      Icons
                          .star_outline_rounded,

                  text:
                      '${nursery.ratingLabel} rating'
                      '${nursery.userRatingsTotal != null ? ' • ${nursery.userRatingsTotal} reviews' : ''}',
                ),

              // Open status
              if (hasOpenStatus)
                _DetailRow(
                  icon:
                      Icons
                          .access_time_rounded,

                  text:
                      nursery
                          .openStatusLabel,

                  color:
                      nursery.isOpen!
                          ? AppColors
                              .primary
                          : AppColors
                              .error,
                ),

              // Place type
              if (hasPlaceType)
                _DetailRow(
                  icon:
                      Icons
                          .local_florist_outlined,

                  text:
                      nursery.placeType!,
                ),

              const SizedBox(
                height:
                    AppSpacing.lg,
              ),

              // ==================================================
              // ACTIONS
              // ==================================================

              Row(
                children: [
                  // ------------------------------------------------
                  // DIRECTIONS
                  // ------------------------------------------------

                  Expanded(
                    child:
                        FilledButton.icon(
                      onPressed:
                          _openDirections,

                      icon:
                          const Icon(
                        Icons
                            .directions_rounded,
                      ),

                      label:
                          const Text(
                        'Directions',
                      ),

                      style:
                          FilledButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .primary,

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            AppRadius
                                .circular,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ------------------------------------------------
                  // PHONE
                  // ------------------------------------------------

                  if (hasPhone) ...[
                    const SizedBox(
                      width:
                          AppSpacing.sm,
                    ),

                    _ActionIconButton(
                      icon:
                          Icons
                              .phone_outlined,

                      tooltip:
                          'Call nursery',

                      onPressed:
                          _callNursery,
                    ),
                  ],

                  // ------------------------------------------------
                  // WEBSITE
                  // ------------------------------------------------

                  if (hasWebsite) ...[
                    const SizedBox(
                      width:
                          AppSpacing.sm,
                    ),

                    _ActionIconButton(
                      icon:
                          Icons
                              .language_rounded,

                      tooltip:
                          'Open website',

                      onPressed:
                          _openWebsite,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom:
            AppSpacing.sm,
      ),

      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 20,
            color:
                color ??
                    AppColors
                        .textSecondary,
          ),

          const SizedBox(
            width:
                AppSpacing.sm,
          ),

          Expanded(
            child:
                Text(
              text,

              style:
                  AppTextStyles.body
                      .copyWith(
                color:
                    color ??
                        AppColors
                            .textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION ICON BUTTON
// ============================================================

class _ActionIconButton
    extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Tooltip(
      message: tooltip,

      child: IconButton(
        onPressed:
            onPressed,

        style:
            IconButton.styleFrom(
          backgroundColor:
              AppColors.background,

          foregroundColor:
              AppColors.primary,

          minimumSize:
              const Size(
            48,
            48,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppRadius.circular,
            ),
          ),
        ),

        icon:
            Icon(
          icon,
          size: 22,
        ),
      ),
    );
  }
}