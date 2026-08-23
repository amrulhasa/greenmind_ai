import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../chatbot/providers/chatbot_provider.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../providers/disease_provider.dart';

class DiseaseResultCard extends ConsumerWidget {
  const DiseaseResultCard({super.key});

  // ==========================================================
  // ASK GREENMIND AI
  // ==========================================================

  Future<void> _askGreenMindAI(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result =
        ref.read(diseaseProvider).result;

    if (result == null) {
      return;
    }

    // ----------------------------------------------------------
    // PREPARE DISEASE INFORMATION
    // ----------------------------------------------------------

    final diseaseName =
        result.diseaseName.trim().isEmpty
            ? 'Unknown condition'
            : result.diseaseName.trim();

    final confidence =
        result.confidence
            .clamp(0.0, 100.0)
            .toStringAsFixed(1);

    final description =
        result.description.trim().isEmpty
            ? 'No description available.'
            : result.description.trim();

    final symptoms =
        result.symptoms.trim().isEmpty
            ? 'No symptom information available.'
            : result.symptoms.trim();

    final treatment =
        result.treatment.trim().isEmpty
            ? 'No treatment information available.'
            : result.treatment.trim();

    final prevention =
        result.prevention.trim().isEmpty
            ? 'No prevention information available.'
            : result.prevention.trim();

    // ----------------------------------------------------------
    // CREATE AI PROMPT
    // ----------------------------------------------------------

    final prompt = '''
I have just analyzed a plant using GreenMind AI's plant disease detection system.

Here is the detection result:

Detected condition: $diseaseName
Confidence: $confidence%
Plant appears healthy: ${result.isHealthy}

Description:
$description

Symptoms:
$symptoms

Treatment:
$treatment

Prevention:
$prevention

Please act as GreenMind AI, my plant care assistant.

Based on this detection result:

1. Explain the condition in simple language.
2. Tell me whether the result may be serious.
3. Explain what I should do next.
4. Give practical plant-care recommendations.
5. Explain how I can prevent the problem from getting worse.
6. If the AI detection may be uncertain, clearly tell me that.
7. Do not claim that the image-based detection is 100% certain.

Keep the answer practical, clear, and easy to understand.
''';

    // ----------------------------------------------------------
    // GET CHATBOT NOTIFIER
    // ----------------------------------------------------------

    final chatbotNotifier =
        ref.read(chatbotProvider.notifier);

    // ----------------------------------------------------------
    // SEND MESSAGE
    // ----------------------------------------------------------

    final responseFuture =
        chatbotNotifier.sendMessage(prompt);

    // ----------------------------------------------------------
    // OPEN CHATBOT
    // ----------------------------------------------------------

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const ChatbotScreen(),
      ),
    );

    // ----------------------------------------------------------
    // WAIT FOR AI RESPONSE
    // ----------------------------------------------------------

    await responseFuture;
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state =
        ref.watch(diseaseProvider);

    final result = state.result;

    // ==========================================================
    // NO RESULT
    // ==========================================================

    if (result == null) {
      return const SizedBox.shrink();
    }

    // ==========================================================
    // CONFIDENCE
    // ==========================================================

    final confidence =
        result.confidence.clamp(0.0, 100.0);

    // ==========================================================
    // MAIN RESULT CARD
    // ==========================================================

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // ======================================================
          // HEADER
          // ======================================================

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: result.isHealthy
                      ? Colors.green.withValues(
                          alpha: 0.10,
                        )
                      : Colors.red.withValues(
                          alpha: 0.10,
                        ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result.isHealthy
                      ? Icons
                          .check_circle_outline
                      : Icons
                          .health_and_safety_outlined,
                  color: result.isHealthy
                      ? Colors.green
                      : Colors.red,
                  size: 26,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: Text(
                  'Disease Detection Result',
                  style:
                      AppTextStyles.heading3,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          // ======================================================
          // DISEASE NAME
          // ======================================================

          Text(
            result.diseaseName
                    .trim()
                    .isEmpty
                ? 'Unknown Condition'
                : result.diseaseName,
            style:
                AppTextStyles.heading2,
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          // ======================================================
          // CONFIDENCE
          // ======================================================

          Text(
            'Confidence',
            style:
                AppTextStyles.heading3,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child:
                LinearProgressIndicator(
              value:
                  confidence / 100,
              minHeight: 8,
              backgroundColor:
                  AppColors.primary
                      .withValues(
                alpha: 0.10,
              ),
              color: result.isHealthy
                  ? Colors.green
                  : AppColors.primary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child: Text(
              '${confidence.toStringAsFixed(1)}%',
              style:
                  AppTextStyles.body.copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          if (result.description
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Description',
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              result.description,
              style:
                  AppTextStyles.body,
            ),
          ],

          // ======================================================
          // SYMPTOMS
          // ======================================================

          if (result.symptoms
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Symptoms',
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              result.symptoms,
              style:
                  AppTextStyles.body,
            ),
          ],

          // ======================================================
          // TREATMENT
          // ======================================================

          if (result.treatment
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Treatment',
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              result.treatment,
              style:
                  AppTextStyles.body,
            ),
          ],

          // ======================================================
          // PREVENTION
          // ======================================================

          if (result.prevention
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Prevention',
              style:
                  AppTextStyles.heading3,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              result.prevention,
              style:
                  AppTextStyles.body,
            ),
          ],

          // ======================================================
          // HEALTH STATUS
          // ======================================================

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  AppSpacing.md,
              vertical:
                  AppSpacing.sm,
            ),
            decoration:
                BoxDecoration(
              color: result.isHealthy
                  ? Colors.green.withValues(
                      alpha: 0.10,
                    )
                  : Colors.red.withValues(
                      alpha: 0.10,
                    ),
              borderRadius:
                  BorderRadius.circular(
                AppRadius.card,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.isHealthy
                      ? Icons
                          .check_circle_outline
                      : Icons
                          .warning_amber_rounded,
                  color: result.isHealthy
                      ? Colors.green
                      : Colors.red,
                  size: 24,
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                Expanded(
                  child: Text(
                    result.isHealthy
                        ? 'Plant appears healthy'
                        : 'Possible disease detected',
                    style:
                        AppTextStyles.body
                            .copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // ONLY ONE ASK GREENMIND AI BUTTON
          // ======================================================

          const SizedBox(
            height: AppSpacing.lg,
          ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child:
                ElevatedButton.icon(
              onPressed: () {
                _askGreenMindAI(
                  context,
                  ref,
                );
              },
              icon: const Icon(
                Icons.smart_toy_rounded,
                size: 22,
              ),
              label: const Text(
                'Ask GreenMind AI',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.card,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          // ======================================================
          // INFO TEXT
          // ======================================================

          Center(
            child: Text(
              'Get personalized guidance from GreenMind AI',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}