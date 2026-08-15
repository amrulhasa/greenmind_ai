import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        margin: const EdgeInsets.only(
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(
              AppRadius.card,
            ),
            topRight: const Radius.circular(
              AppRadius.card,
            ),
            bottomLeft: Radius.circular(
              isUser ? AppRadius.card : 4,
            ),
            bottomRight: Radius.circular(
              isUser ? 4 : AppRadius.card,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body.copyWith(
            color: isUser
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TYPING INDICATOR
// ==========================================

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() =>
      _TypingIndicatorState();
}

class _TypingIndicatorState
    extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(
              AppRadius.card,
            ),
            topRight: Radius.circular(
              AppRadius.card,
            ),
            bottomRight: Radius.circular(
              AppRadius.card,
            ),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = _controller.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GreenMind AI is thinking',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                _TypingDot(
                  animationValue: value,
                  delay: 0.0,
                ),
                _TypingDot(
                  animationValue: value,
                  delay: 0.2,
                ),
                _TypingDot(
                  animationValue: value,
                  delay: 0.4,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// TYPING DOT
// ==========================================

class _TypingDot extends StatelessWidget {
  final double animationValue;
  final double delay;

  const _TypingDot({
    required this.animationValue,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    double value = animationValue - delay;

    if (value < 0) {
      value += 1;
    }

    final opacity = 0.35 +
        (0.65 *
            (value < 0.5
                ? value * 2
                : (1 - value) * 2));

    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
      ),
      child: Opacity(
        opacity: opacity.clamp(0.35, 1.0),
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}