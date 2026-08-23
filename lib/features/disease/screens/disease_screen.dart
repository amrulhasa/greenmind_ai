import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/detect_button.dart';
import '../widgets/disease_picker_card.dart';
import '../widgets/disease_preview.dart';
import '../widgets/disease_result_card.dart';

class DiseaseScreen extends StatelessWidget {
  const DiseaseScreen({super.key});

  // ==============================================================
  // COLORS
  // ==============================================================

  static const Color _background = Color(0xFFF5F9F5);
  static const Color _textDark = Color(0xFF182019);

  // ==============================================================
  // GO HOME
  // ==============================================================

  void _goHome(BuildContext context) {
    context.go('/home');
  }

  // ==============================================================
  // BUILD
  // ==============================================================

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
        backgroundColor: _background,

        // ========================================================
        // APP BAR
        // ========================================================

        appBar: AppBar(
          backgroundColor: _background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,

          leading: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: IconButton(
              onPressed: () {
                _goHome(context);
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 21,
              ),
              tooltip: 'Back',
            ),
          ),

          title: const Text(
            'Disease Detection',
            style: TextStyle(
              color: _textDark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),

          centerTitle: true,

          actions: [
            const SizedBox(width: 58),
          ],
        ),

        // ========================================================
        // BODY
        // ========================================================

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              32,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HERO SECTION
                // ==================================================

                _DiseaseHeroSection(),

                const SizedBox(
                  height: 22,
                ),

                // ==================================================
                // IMAGE PICKER SECTION
                // ==================================================

                _SectionLabel(
                  icon: Icons.photo_camera_back_outlined,
                  title: 'Upload Plant Image',
                  subtitle:
                      'Choose a clear photo of the affected leaf',
                ),

                const SizedBox(
                  height: 12,
                ),

                const DiseasePickerCard(),

                const SizedBox(
                  height: 22,
                ),

                // ==================================================
                // IMAGE PREVIEW SECTION
                // ==================================================

                _SectionLabel(
                  icon: Icons.image_outlined,
                  title: 'Image Preview',
                  subtitle:
                      'Make sure the leaf is clearly visible',
                ),

                const SizedBox(
                  height: 12,
                ),

                const DiseasePreview(),

                const SizedBox(
                  height: 22,
                ),

                // ==================================================
                // DETECTION SECTION
                // ==================================================

                _DetectionInfoCard(),

                const SizedBox(
                  height: 14,
                ),

                const DetectButton(),

                const SizedBox(
                  height: 28,
                ),

                // ==================================================
                // RESULT SECTION
                // ==================================================

                _SectionLabel(
                  icon: Icons.analytics_outlined,
                  title: 'Detection Result',
                  subtitle:
                      'AI analysis of your plant image',
                ),

                const SizedBox(
                  height: 12,
                ),

                const DiseaseResultCard(),

                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// DISEASE HERO SECTION
// ==================================================================

class _DiseaseHeroSection extends StatelessWidget {
  const _DiseaseHeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF6EC),
            Color(0xFFF4FAF5),
          ],
        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xFFDCEBDD),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          // --------------------------------------------------------
          // ICON
          // --------------------------------------------------------

          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),

              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Color(0xFF2E7D32),
              size: 31,
            ),
          ),

          const SizedBox(width: 16),

          // --------------------------------------------------------
          // TEXT
          // --------------------------------------------------------

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'AI Plant Health Check',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Upload a clear leaf image and let GreenMind AI analyze it for possible diseases.',
                  style: TextStyle(
                    color: Color(0xFF657067),
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
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

// ==================================================================
// SECTION LABEL
// ==================================================================

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,

      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: const Color(0xFFE8F4EA),
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 20,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF182019),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF7A847B),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// DETECTION INFO CARD
// ==================================================================

class _DetectionInfoCard extends StatelessWidget {
  const _DetectionInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE1E9E2),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EC),
              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF2E7D32),
              size: 18,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Ready for AI Analysis',
                  style: TextStyle(
                    color: Color(0xFF273128),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'GreenMind AI will analyze the uploaded image.',
                  style: TextStyle(
                    color: Color(0xFF7A847B),
                    fontSize: 10.5,
                    height: 1.35,
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