import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/identify_button.dart';
import '../widgets/image_picker_card.dart';
import '../widgets/image_preview.dart';

class IdentifyScreen extends StatelessWidget {
  const IdentifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Identification'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Identify Any Plant',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Take a photo or choose one from your gallery to identify any plant using AI.',
                style: AppTextStyles.body,
              ),

              const SizedBox(height: AppSpacing.xl),

              const ImagePickerCard(),

              const SizedBox(height: AppSpacing.lg),

              const ImagePreview(),

              const SizedBox(height: AppSpacing.xl),

              const IdentifyButton(),
            ],
          ),
        ),
      ),
    );
  }
}