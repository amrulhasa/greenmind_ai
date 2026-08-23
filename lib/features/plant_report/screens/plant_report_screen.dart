import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/plant_care_report.dart';
import '../providers/plant_report_provider.dart';
import '../screens/report_preview_screen.dart';

import '../widgets/report_header.dart';
import '../widgets/health_section.dart';
import '../widgets/disease_analysis_section.dart';
import '../widgets/symptoms_section.dart';
import '../widgets/care_summary_section.dart';
import '../widgets/plant_overview_section.dart';
import '../widgets/recommendations_section.dart';
import '../widgets/care_schedule_section.dart';

class PlantReportScreen extends ConsumerWidget {
  const PlantReportScreen({
    super.key,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor =
      Color(0xFFF5F9F5);

  static const Color primaryGreen =
      Color(0xFF2E7D32);

  static const Color darkText =
      Color(0xFF172018);

  static const Color secondaryText =
      Color(0xFF68736B);

  static const Color errorRed =
      Color(0xFFD32F2F);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final PlantReportState state =
        ref.watch(plantReportProvider);

    // ==========================================================
    // GENERATING
    // ==========================================================

    if (state.isGenerating) {
      return const _GeneratingReportView();
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (state.hasError) {
      return _ErrorView(
        message: state.errorMessage ?? '',
        onBack: () {
          _goBack(context);
        },
      );
    }

    // ==========================================================
    // REPORT
    // ==========================================================

    final PlantCareReport? report =
        state.report;

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (report == null) {
      return const _EmptyReportView();
    }

    // ==========================================================
    // MAIN REPORT
    // ==========================================================

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        backgroundColor: backgroundColor,

        foregroundColor: darkText,

        centerTitle: true,

        title: const Text(
          'Plant Care Report',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        leading: IconButton(
          tooltip: 'Back',

          icon: const Icon(
            Icons.arrow_back_rounded,
          ),

          onPressed: () {
            _goBack(context);
          },
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              ReportHeader(
                report: report,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // HEALTH
              // ==================================================

              HealthSection(
                report: report,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // DISEASE ANALYSIS
              // ==================================================

              DiseaseAnalysisSection(
                report: report,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // SYMPTOMS
              // ==================================================

              SymptomsSection(
                report: report,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // CARE SUMMARY
              // ==================================================

              CareSummarySection(
                report: report,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // PLANT OVERVIEW
              // ==================================================

              PlantOverviewSection(
                report: report,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // RECOMMENDATIONS
              // ==================================================

              RecommendationsSection(
                report: report,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // CARE SCHEDULE
              // ==================================================

              CareScheduleSection(
                report: report,
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // PDF BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton.icon(
                  onPressed: () {
                    _openReportPreview(
                      context,
                      report,
                    );
                  },

                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 21,
                  ),

                  label: const Text(
                    'Generate PDF Report',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryGreen,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // DISCLAIMER
              // ==================================================

              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 8,
                ),

                child: Text(
                  'AI-generated plant-care guidance. '
                  'For severe disease or pest problems, '
                  'consult a qualified horticulture professional.',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color:
                        Color(0xFF7A837C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPEN REPORT PREVIEW
  // ============================================================

  void _openReportPreview(
    BuildContext context,
    PlantCareReport report,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ReportPreviewScreen(
          report: report,
        ),
      ),
    );
  }

  // ============================================================
  // GO BACK
  // ============================================================

  void _goBack(
    BuildContext context,
  ) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/identify');
  }
}

// =================================================================
// GENERATING VIEW
// =================================================================

class _GeneratingReportView
    extends StatelessWidget {
  const _GeneratingReportView();

  static const Color backgroundColor =
      Color(0xFFF5F9F5);

  static const Color primaryGreen =
      Color(0xFF2E7D32);

  static const Color darkText =
      Color(0xFF172018);

  static const Color secondaryText =
      Color(0xFF68736B);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        backgroundColor:
            backgroundColor,

        foregroundColor:
            darkText,

        centerTitle: true,

        title: const Text(
          'Plant Care Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(32),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              // ==================================================
              // AI ICON
              // ==================================================

              Container(
                width: 96,
                height: 96,

                decoration:
                    const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 44,
                  color:
                      primaryGreen,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Preparing Your Plant Report',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      darkText,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              const Text(
                'GreenMind AI is analyzing the plant image, '
                'health condition, care requirements and '
                'personalized recommendations.',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color:
                      secondaryText,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // PROGRESS
              // ==================================================

              const SizedBox(
                width: 34,
                height: 34,

                child:
                    CircularProgressIndicator(
                  strokeWidth: 3,
                  color:
                      primaryGreen,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Generating with Gemini AI...',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 12,
                  color:
                      Color(0xFF7A837C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// EMPTY REPORT VIEW
// =================================================================

class _EmptyReportView
    extends StatelessWidget {
  const _EmptyReportView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F9F5),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        backgroundColor:
            const Color(0xFFF5F9F5),

        foregroundColor:
            const Color(0xFF172018),

        centerTitle: true,

        title: const Text(
          'Plant Care Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 90,
                height: 90,

                decoration:
                    const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.description_outlined,
                  color:
                      Color(0xFF2E7D32),
                  size: 42,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'No Report Available',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF172018),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              const Text(
                'Identify a plant first to generate '
                'a personalized AI care report.',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                      Color(0xFF68736B),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // BACK BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/identify');
                    }
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2E7D32,
                    ),

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),

                  child: const Text(
                    'Go Back',

                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
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

// =================================================================
// ERROR VIEW
// =================================================================

class _ErrorView
    extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onBack,
  });

  // ============================================================
  // QUOTA ERROR DETECTOR
  // ============================================================

  bool get _isQuotaError {
    final text =
        message.toLowerCase();

    return text.contains(
          'quota',
        ) ||
        text.contains(
          'rate limit',
        ) ||
        text.contains(
          'resource exhausted',
        ) ||
        text.contains(
          '429',
        ) ||
        text.contains(
          'free_tier_requests',
        );
  }

  // ============================================================
  // DISPLAY MESSAGE
  // ============================================================

  String get _displayMessage {
    if (_isQuotaError) {
      return 'Gemini AI is temporarily unavailable '
          'because the current API quota has been reached.\n\n'
          'Please wait a little while and try again.';
    }

    if (message.trim().isEmpty) {
      return 'Unable to generate the plant-care report.';
    }

    return message;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool quotaError =
        _isQuotaError;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F9F5),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        backgroundColor:
            const Color(0xFFF5F9F5),

        foregroundColor:
            const Color(0xFF172018),

        centerTitle: true,

        title: const Text(
          'Plant Care Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              // ==================================================
              // ERROR ICON
              // ==================================================

              Container(
                width: 90,
                height: 90,

                decoration:
                    BoxDecoration(
                  color: quotaError
                      ? const Color(
                          0xFFFFF3E0,
                        )
                      : const Color(
                          0xFFFFEBEE,
                        ),
                  shape:
                      BoxShape.circle,
                ),

                child: Icon(
                  quotaError
                      ? Icons.cloud_off_rounded
                      : Icons.error_outline_rounded,

                  size: 48,

                  color: quotaError
                      ? const Color(
                          0xFFEF6C00,
                        )
                      : const Color(
                          0xFFD32F2F,
                        ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                quotaError
                    ? 'AI Service Temporarily Busy'
                    : 'Report Generation Failed',

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF172018),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // MESSAGE
              // ==================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(16),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),

                  border: Border.all(
                    color:
                        const Color(
                      0xFFE4E9E5,
                    ),
                  ),
                ),

                child: Text(
                  _displayMessage,

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color:
                        Color(0xFF68736B),
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // BACK BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: onBack,

                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),

                  label: const Text(
                    'Go Back',
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2E7D32,
                    ),

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
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