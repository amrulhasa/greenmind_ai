import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggestion_chip.dart';

class ChatbotScreen extends ConsumerWidget {
  const ChatbotScreen({super.key});

  static const List<String> _suggestions = [
    'How often should I water my plant?',
    'Why are my leaves turning yellow?',
    'How can I prevent plant diseases?',
    'What fertilizer should I use?',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotProvider);
    final notifier = ref.read(chatbotProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GreenMind AI',
                  style: AppTextStyles.title,
                ),
                Text(
                  'Plant Assistant',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            onPressed: state.messages.length <= 1
                ? null
                : notifier.clearChat,
            icon: const Icon(
              Icons.delete_outline_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.length == 1
                ? _buildWelcomeContent(
                    context,
                    notifier,
                  )
                : _buildMessageList(state),
          ),
          if (state.errorMessage != null)
            _ErrorMessage(
              message: state.errorMessage!,
            ),
          const ChatInput(),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent(
    BuildContext context,
    ChatbotNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),

          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Center(
            child: Text(
              'How can I help your plant?',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Center(
            child: Text(
              'Ask me about watering, sunlight, soil, '
              'fertilizer, diseases, and everyday plant care.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Try asking',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppSpacing.md),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _suggestions.map(
              (suggestion) {
                return SuggestionChip(
                  label: suggestion,
                  onPressed: () {
                    notifier.sendMessage(suggestion);
                  },
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatbotState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      reverse: false,
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        return ChatBubble(
          message: state.messages[index],
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: AppColors.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}