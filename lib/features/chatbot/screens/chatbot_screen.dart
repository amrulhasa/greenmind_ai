import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggestion_chip.dart';

class ChatbotScreen
    extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen>
      createState() =>
          _ChatbotScreenState();
}

class _ChatbotScreenState
    extends ConsumerState<ChatbotScreen> {
  final ScrollController
      _scrollController =
      ScrollController();

  static const List<String>
      _suggestions = [
    'How often should I water my plant?',
    'Why are my leaves turning yellow?',
    'How can I prevent plant diseases?',
    'What fertilizer should I use?',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // GO HOME
  // ============================================================

  void _goHome(BuildContext context) {
    context.go('/home');
  }

  // ============================================================
  // AUTO SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!_scrollController
          .hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController
            .position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final state =
        ref.watch(chatbotProvider);

    final notifier = ref.read(
      chatbotProvider.notifier,
    );

    // ==========================================================
    // LISTEN FOR CHAT STATE CHANGES
    // ==========================================================

    ref.listen<ChatbotState>(
      chatbotProvider,
      (previous, next) {
        if (previous == null) {
          return;
        }

        // New message added
        if (next.messages.length !=
            previous.messages.length) {
          _scrollToBottom();
        }

        // AI started thinking
        if (next.isLoading &&
            !previous.isLoading) {
          _scrollToBottom();
        }

        // AI finished responding
        if (!next.isLoading &&
            previous.isLoading) {
          _scrollToBottom();
        }
      },
    );

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
          // ======================================================
          // BACK BUTTON
          // ======================================================

          leading: IconButton(
            onPressed: () {
              _goHome(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            tooltip: 'Back',
          ),

          // ======================================================
          // AI HEADER
          // ======================================================

          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color:
                      AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'GreenMind AI',
                    style:
                        AppTextStyles.title,
                  ),
                  Text(
                    'Plant Assistant',
                    style:
                        AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // CLEAR CHAT
          // ======================================================

          actions: [
            IconButton(
              tooltip: 'Clear chat',
              onPressed:
                  state.messages.length <= 1
                      ? null
                      : notifier.clearChat,
              icon: const Icon(
                Icons
                    .delete_outline_rounded,
              ),
            ),
          ],
        ),

        // ========================================================
        // BODY
        // ========================================================

        body: Column(
          children: [
            // ====================================================
            // CHAT AREA
            // ====================================================

            Expanded(
              child:
                  state.messages.length ==
                          1
                      ? _buildWelcomeContent(
                          context,
                          notifier,
                        )
                      : _buildMessageList(
                          state,
                        ),
            ),

            // ====================================================
            // ERROR
            // ====================================================

            if (state.errorMessage !=
                null)
              _ErrorMessage(
                message:
                    state.errorMessage!,
              ),

            // ====================================================
            // INPUT
            // ====================================================

            const ChatInput(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME CONTENT
  // ============================================================

  Widget _buildWelcomeContent(
    BuildContext context,
    ChatbotNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // AI ICON
          // ======================================================

          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration:
                  BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 48,
                color:
                    AppColors.primary,
              ),
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          // ======================================================
          // TITLE
          // ======================================================

          Center(
            child: Text(
              'How can I help your plant?',
              style:
                  AppTextStyles.heading2,
              textAlign:
                  TextAlign.center,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          Center(
            child: Text(
              'Ask me about watering, sunlight, soil, '
              'fertilizer, diseases, and everyday plant care.',
              style:
                  AppTextStyles.body,
              textAlign:
                  TextAlign.center,
            ),
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          // ======================================================
          // SUGGESTIONS
          // ======================================================

          Text(
            'Try asking',
            style:
                AppTextStyles.heading3,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Wrap(
            spacing:
                AppSpacing.sm,
            runSpacing:
                AppSpacing.sm,
            children:
                _suggestions.map(
              (suggestion) {
                return SuggestionChip(
                  label: suggestion,
                  onPressed: () {
                    notifier
                        .sendMessage(
                      suggestion,
                    );
                  },
                );
              },
            ).toList(),
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE LIST
  // ============================================================

  Widget _buildMessageList(
    ChatbotState state,
  ) {
    final int itemCount =
        state.messages.length +
            (state.isLoading ? 1 : 0);

    return ListView.builder(
      controller:
          _scrollController,
      padding:
          const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.xl,
      ),
      itemCount: itemCount,
      itemBuilder:
          (context, index) {
        // ======================================================
        // TYPING INDICATOR
        // ======================================================

        if (state.isLoading &&
            index ==
                state.messages.length) {
          return const Padding(
            padding: EdgeInsets.only(
              bottom: AppSpacing.sm,
            ),
            child:
                TypingIndicator(),
          );
        }

        // ======================================================
        // CHAT MESSAGE
        // ======================================================

        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: AppSpacing.sm,
          ),
          child: ChatBubble(
            message:
                state.messages[index],
          ),
        );
      },
    );
  }
}

// ============================================================
// ERROR MESSAGE
// ============================================================

class _ErrorMessage
    extends StatelessWidget {
  final String message;

  const _ErrorMessage({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      padding:
          const EdgeInsets.all(
        AppSpacing.sm,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.error
            .withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style:
            AppTextStyles.body
                .copyWith(
          color:
              AppColors.error,
        ),
        textAlign:
            TextAlign.center,
      ),
    );
  }
}