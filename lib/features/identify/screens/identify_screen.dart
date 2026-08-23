import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../plant_report/providers/plant_report_provider.dart';
import '../providers/identify_provider.dart';
import '../widgets/identify_button.dart';
import '../widgets/identify_result_card.dart';
import '../widgets/image_picker_card.dart';
import '../widgets/image_preview.dart';

class IdentifyScreen extends ConsumerWidget {
  const IdentifyScreen({
    super.key,
  });

  // ============================================================
  // GO HOME
  // ============================================================

  void _goHome(BuildContext context) {
    if (!context.mounted) {
      return;
    }

    context.go('/home');
  }

  // ============================================================
  // GENERATE PLANT REPORT
  // ============================================================

  Future<void> _generatePlantReport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // ----------------------------------------------------------
    // READ IDENTIFICATION STATE
    // ----------------------------------------------------------

    final identifyState = ref.read(identifyProvider);

    // ----------------------------------------------------------
    // PREVENT DUPLICATE REPORT GENERATION
    // ----------------------------------------------------------

    final reportState = ref.read(plantReportProvider);

    if (reportState.isGenerating) {
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE IDENTIFICATION RESULT
    // ----------------------------------------------------------

    final result = identifyState.result;

    if (result == null) {
      _showMessage(
        context,
        'Please identify the plant first.',
        isError: true,
      );

      return;
    }

    // ----------------------------------------------------------
    // VALIDATE IMAGE
    // ----------------------------------------------------------

    final imageBytes = identifyState.imageBytes;

    if (imageBytes == null || imageBytes.isEmpty) {
      _showMessage(
        context,
        'Plant image is not available. Please select an image again.',
        isError: true,
      );

      return;
    }

    // ----------------------------------------------------------
    // CLEAR PREVIOUS REPORT
    // ----------------------------------------------------------

    ref
        .read(plantReportProvider.notifier)
        .clearReport();

    // ----------------------------------------------------------
    // GENERATE REPORT
    // ----------------------------------------------------------

    try {
      await ref
          .read(plantReportProvider.notifier)
          .generateImageReport(
            identification: result,
            imageBytes: imageBytes,
          );
    } catch (error) {
      debugPrint(
        'PLANT REPORT GENERATION ERROR: $error',
      );

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Unable to generate plant report. Please try again.',
        isError: true,
      );

      return;
    }

    // ----------------------------------------------------------
    // CHECK SCREEN
    // ----------------------------------------------------------

    if (!context.mounted) {
      return;
    }

    // ----------------------------------------------------------
    // READ UPDATED REPORT STATE
    // ----------------------------------------------------------

    final updatedReportState =
        ref.read(plantReportProvider);

    // ----------------------------------------------------------
    // REPORT ERROR
    // ----------------------------------------------------------

    if (updatedReportState.hasError) {
      _showMessage(
        context,
        updatedReportState.errorMessage ??
            'Unable to generate plant report.',
        isError: true,
      );

      return;
    }

    // ----------------------------------------------------------
    // REPORT SUCCESS
    // ----------------------------------------------------------

    if (updatedReportState.hasReport) {
      context.push('/plant-report');
      return;
    }

    // ----------------------------------------------------------
    // FALLBACK
    // ----------------------------------------------------------

    _showMessage(
      context,
      'Plant report could not be generated. Please try again.',
      isError: true,
    );
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) {
      return;
    }

    final messenger =
        ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final identifyState =
        ref.watch(identifyProvider);

    final reportState =
        ref.watch(plantReportProvider);

    // ----------------------------------------------------------
    // IDENTIFICATION STATUS
    // ----------------------------------------------------------

    final hasResult =
        identifyState.result != null;

    final hasImage =
        identifyState.imageBytes != null &&
        identifyState.imageBytes!.isNotEmpty;

    // ----------------------------------------------------------
    // REPORT STATUS
    // ----------------------------------------------------------

    final isGeneratingReport =
        reportState.isGenerating;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (didPop, result) {
        if (didPop) {
          return;
        }

        _goHome(context);
      },
      child: Scaffold(
        // ======================================================
        // APP BAR
        // ======================================================

        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () {
              _goHome(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),
          title: const Text(
            'Plant Identification',
          ),
          centerTitle: true,
        ),

        // ======================================================
        // BODY
        // ======================================================

        body: SafeArea(
          child: SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              32,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                const _IdentifyHeader(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ==================================================
                // IMAGE PICKER
                // ==================================================

                const ImagePickerCard(),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                // ==================================================
                // IMAGE PREVIEW
                // ==================================================

                const ImagePreview(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ==================================================
                // IDENTIFY BUTTON
                // ==================================================

                const IdentifyButton(),

                // ==================================================
                // IDENTIFICATION LOADING
                // ==================================================

                if (identifyState.isLoading) ...[
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  const _IdentificationLoadingCard(),
                ],

                // ==================================================
                // IDENTIFICATION ERROR
                // ==================================================

                if (identifyState.errorMessage !=
                    null) ...[
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  _ErrorCard(
                    message:
                        identifyState.errorMessage!,
                  ),
                ],

                // ==================================================
                // IMAGE READY
                // ==================================================

                if (!identifyState.isLoading &&
                    !hasResult &&
                    identifyState.errorMessage ==
                        null &&
                    hasImage) ...[
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  const _ImageReadyCard(),
                ],

                // ==================================================
                // AI RESULT
                // ==================================================

                if (hasResult) ...[
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  const _SectionTitle(
                    title:
                        'AI Identification Result',
                    subtitle:
                        'Your plant has been analyzed successfully.',
                    icon:
                        Icons.auto_awesome_rounded,
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  IdentifyResultCard(
                    result:
                        identifyState.result!,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // =================================================
                  // REPORT GENERATION
                  // =================================================

                  _ReportGenerationCard(
                    isGenerating:
                        isGeneratingReport,
                    onGenerate: () {
                      _generatePlantReport(
                        context,
                        ref,
                      );
                    },
                  ),
                ],

                // ==================================================
                // HOW IT WORKS
                // ==================================================

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                if (!hasResult &&
                    !identifyState.isLoading)
                  const _HowItWorksCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// IDENTIFY HEADER
// ================================================================

class _IdentifyHeader
    extends StatelessWidget {
  const _IdentifyHeader();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Identify Any Plant',
          style:
              AppTextStyles.heading1,
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        Text(
          'Take a photo or choose one from your gallery to identify the plant using AI.',
          style:
              AppTextStyles.body,
        ),

        const SizedBox(
          height: 18,
        ),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFEAF6EC),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color:
                  const Color(0xFF2E7D32)
                      .withValues(
                alpha: 0.10,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFD8F0DC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .psychology_alt_rounded,
                  size: 18,
                  color:
                      Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Expanded(
                child: Text(
                  'GreenMind AI will analyze your plant image and provide personalized insights.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        Color(0xFF47614D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// SECTION TITLE
// ================================================================

class _SectionTitle
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color:
                const Color(0xFFE8F5E9),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFF2E7D32),
            size: 21,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color:
                      Color(0xFF68736B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// IDENTIFICATION LOADING
// ================================================================

class _IdentificationLoadingCard
    extends StatelessWidget {
  const _IdentificationLoadingCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF3F8F3),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFF2E7D32)
                  .withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child:
                CircularProgressIndicator(
              strokeWidth: 3,
              color:
                  Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Analyzing your plant...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Text(
                  'GreenMind AI is identifying the plant and analyzing the image.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        Color(0xFF68736B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ERROR CARD
// ================================================================

class _ErrorCard
    extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Colors.red.withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.red.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color:
                Colors.redAccent,
            size: 22,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color:
                    Color(0xFF9E2B2B),
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// IMAGE READY CARD
// ================================================================

class _ImageReadyCard
    extends StatelessWidget {
  const _ImageReadyCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF5F8F5),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFDCE7DE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFE2F2E4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color:
                  Color(0xFF2E7D32),
              size: 21,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Text(
              'Image selected. Press "Identify Plant" to start the AI analysis.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color:
                    Color(0xFF5F6962),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// REPORT GENERATION CARD
// ================================================================

class _ReportGenerationCard
    extends StatelessWidget {
  final bool isGenerating;
  final VoidCallback onGenerate;

  const _ReportGenerationCard({
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFF0F8F1),
            Color(0xFFE6F3E8),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFF2E7D32)
                  .withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFD9EFD9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGenerating
                      ? Icons
                          .auto_awesome_rounded
                      : Icons
                          .description_rounded,
                  color:
                      const Color(
                    0xFF2E7D32,
                  ),
                  size: 23,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Plant Care Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF1F2A21),
                      ),
                    ),

                    SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Get a personalized care plan based on this identification.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color:
                            Color(0xFF607064),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // REPORT FEATURES
          // ------------------------------------------------------

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ReportFeature(
                icon:
                    Icons.favorite_rounded,
                text:
                    'Health Analysis',
              ),
              _ReportFeature(
                icon:
                    Icons.water_drop_rounded,
                text:
                    'Care Guidance',
              ),
              _ReportFeature(
                icon:
                    Icons.calendar_month_rounded,
                text:
                    'Care Schedule',
              ),
              _ReportFeature(
                icon:
                    Icons.lightbulb_rounded,
                text:
                    'Recommendations',
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // ------------------------------------------------------
          // GENERATE BUTTON
          // ------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed:
                  isGenerating
                      ? null
                      : onGenerate,
              icon: isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons
                          .auto_awesome_rounded,
                    ),
              label: Text(
                isGenerating
                    ? 'Preparing Your Report...'
                    : 'Generate Plant Report',
              ),
            ),
          ),

          // ------------------------------------------------------
          // LOADING MESSAGE
          // ------------------------------------------------------

          if (isGenerating) ...[
            const SizedBox(
              height: 12,
            ),

            const Center(
              child: Text(
                'Preparing your personalized plant care report...',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      Color(0xFF68736B),
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
// REPORT FEATURE
// ================================================================

class _ReportFeature
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ReportFeature({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white
            .withValues(
          alpha: 0.72,
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                const Color(0xFF2E7D32),
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF536057),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HOW IT WORKS
// ================================================================

class _HowItWorksCard
    extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              Theme.of(context)
                  .dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'How GreenMind AI works',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          const _FlowStep(
            number: '1',
            title: 'Choose a plant image',
            description:
                'Take a photo or select one from your gallery.',
          ),

          const _FlowStep(
            number: '2',
            title: 'AI identifies the plant',
            description:
                'GreenMind AI analyzes the image and identifies the plant.',
          ),

          const _FlowStep(
            number: '3',
            title: 'Generate your care report',
            description:
                'Get health insights, care guidance and a personalized schedule.',
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FLOW STEP
// ================================================================

class _FlowStep
    extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _FlowStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            alignment:
                Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF2E7D32),
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color:
                        Color(0xFF747D76),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}