import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/identify_provider.dart';
import '../widgets/identify_button.dart';
import '../widgets/identify_result_card.dart';
import '../widgets/image_picker_card.dart';
import '../widgets/image_preview.dart';

class IdentifyScreen
    extends ConsumerWidget {
  const IdentifyScreen({
    super.key,
  });

  void _goHome(
    BuildContext context,
  ) {
    context.go('/home');
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state =
        ref.watch(
      identifyProvider,
    );

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
        appBar: AppBar(
          leading:
              IconButton(
            onPressed: () {
              _goHome(context);
            },
            icon: const Icon(
              Icons
                  .arrow_back_rounded,
            ),
          ),
          title: const Text(
            'Plant Identification',
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Identify Any Plant',
                  style:
                      AppTextStyles.heading1,
                ),

                const SizedBox(
                  height:
                      AppSpacing.sm,
                ),

                Text(
                  'Take a photo or choose one from your gallery to identify any plant using AI.',
                  style:
                      AppTextStyles.body,
                ),

                const SizedBox(
                  height:
                      AppSpacing.xl,
                ),

                const ImagePickerCard(),

                const SizedBox(
                  height:
                      AppSpacing.lg,
                ),

                const ImagePreview(),

                const SizedBox(
                  height:
                      AppSpacing.xl,
                ),

                const IdentifyButton(),

                const SizedBox(
                  height:
                      AppSpacing.xl,
                ),

                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        20,
                      ),
                      child:
                          CircularProgressIndicator(),
                    ),
                  ),

                if (state.errorMessage !=
                    null) ...[
                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .all(
                      16,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.red
                          .withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      border: Border.all(
                        color: Colors.red
                            .withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style:
                          AppTextStyles.body
                              .copyWith(
                        color:
                            Colors.red,
                      ),
                    ),
                  ),
                ],

                if (state.result !=
                    null) ...[
                  const SizedBox(
                    height:
                        AppSpacing.xl,
                  ),
                  const Text(
                    'AI Identification Result',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  IdentifyResultCard(
                    result:
                        state.result!,
                  ),
                ],

                if (!state.isLoading &&
                    state.result ==
                        null &&
                    state.errorMessage ==
                        null &&
                    state.imageBytes !=
                        null) ...[
                  const SizedBox(
                    height: 20,
                  ),
                  const Center(
                    child: Text(
                      'Image selected. Press "Identify Plant".',
                      style: TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}