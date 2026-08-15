import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/detect_button.dart';
import '../widgets/disease_picker_card.dart';
import '../widgets/disease_preview.dart';
import '../widgets/disease_result_card.dart';

class DiseaseScreen extends StatelessWidget {
  const DiseaseScreen({super.key});

  void _goHome(BuildContext context) {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) {
        if (didPop) {
          return;
        }

        _goHome(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _goHome(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            tooltip: 'Back',
          ),
          title: const Text(
            'Disease Detection',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Detect Plant Disease',
                  style:
                      AppTextStyles.heading1,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  'Upload a clear leaf image to detect diseases using AI.',
                  style:
                      AppTextStyles.body,
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                const DiseasePickerCard(),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                const DiseasePreview(),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                const DetectButton(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                const DiseaseResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}