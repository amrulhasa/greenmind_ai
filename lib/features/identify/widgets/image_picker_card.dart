import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/identify_provider.dart';

class ImagePickerCard
    extends ConsumerWidget {
  const ImagePickerCard({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final notifier =
        ref.read(
      identifyProvider.notifier,
    );

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.primary
              .withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_rounded,
            size: 64,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            'Upload Plant Image',
            style:
                AppTextStyles.heading3,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            'Choose an image from your gallery or take a photo.',
            textAlign:
                TextAlign.center,
            style:
                AppTextStyles.body,
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed:
                      notifier
                          .pickFromGallery,
                  icon: const Icon(
                    Icons
                        .photo_library_outlined,
                  ),
                  label:
                      const Text(
                    'Gallery',
                  ),
                ),
              ),

              const SizedBox(
                width:
                    AppSpacing.md,
              ),

              Expanded(
                child:
                    ElevatedButton.icon(
                  onPressed:
                      notifier
                          .pickFromCamera,
                  icon: const Icon(
                    Icons
                        .photo_camera_outlined,
                  ),
                  label:
                      const Text(
                    'Camera',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}