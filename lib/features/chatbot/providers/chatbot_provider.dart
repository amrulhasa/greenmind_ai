import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../services/chatbot_service.dart';

// ============================================================
// CHATBOT SERVICE PROVIDER
// ============================================================

final chatbotServiceProvider = Provider<ChatbotService>(
  (ref) => ChatbotService(),
);

// ============================================================
// CHATBOT STATE PROVIDER
// ============================================================

final chatbotProvider = NotifierProvider<ChatbotNotifier, ChatbotState>(
  ChatbotNotifier.new,
);

// ============================================================
// CHATBOT NOTIFIER
// ============================================================

class ChatbotNotifier extends Notifier<ChatbotState> {
  final Uuid _uuid = const Uuid();

  // ----------------------------------------------------------
  // SERVICE
  // ----------------------------------------------------------

  ChatbotService get _service {
    return ref.read(chatbotServiceProvider);
  }

  // ----------------------------------------------------------
  // INITIAL STATE
  // ----------------------------------------------------------

  @override
  ChatbotState build() {
    return ChatbotState(messages: [_createWelcomeMessage()]);
  }

  // ----------------------------------------------------------
  // WELCOME MESSAGE
  // ----------------------------------------------------------

  ChatMessage _createWelcomeMessage() {
    return ChatMessage(
      id: _uuid.v4(),
      text: 'Hello! I am GreenMind AI. Ask me anything about your plants.',
      role: ChatMessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  // ----------------------------------------------------------
  // SEND MESSAGE
  // ----------------------------------------------------------

  Future<void> sendMessage(String text) async {
    final message = text.trim();

    // Ignore empty messages.
    if (message.isEmpty) {
      return;
    }

    // Prevent multiple requests at the same time.
    if (state.isLoading) {
      return;
    }

    // --------------------------------------------------------
    // CREATE USER MESSAGE
    // --------------------------------------------------------

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: message,
      role: ChatMessageRole.user,
      timestamp: DateTime.now(),
    );

    // --------------------------------------------------------
    // UPDATE STATE
    // --------------------------------------------------------

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      errorMessage: null,
    );

    try {
      // ------------------------------------------------------
      // SEND MESSAGE TO AI SERVICE
      // ------------------------------------------------------

      debugPrint('========================================');
      debugPrint('GREENMIND CHATBOT');
      debugPrint('Sending message...');
      debugPrint('========================================');

      final response = await _service.sendMessage(message);

      // ------------------------------------------------------
      // CREATE ASSISTANT MESSAGE
      // ------------------------------------------------------

      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        text: response,
        role: ChatMessageRole.assistant,
        timestamp: DateTime.now(),
      );

      // ------------------------------------------------------
      // UPDATE STATE WITH AI RESPONSE
      // ------------------------------------------------------

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
        errorMessage: null,
      );

      debugPrint('========================================');
      debugPrint('GREENMIND CHATBOT');
      debugPrint('AI response received successfully.');
      debugPrint('========================================');
    } catch (error, stackTrace) {
      // ------------------------------------------------------
      // LOG ERROR
      // ------------------------------------------------------

      debugPrint('========================================');
      debugPrint('GREENMIND CHATBOT ERROR');
      debugPrint('========================================');
      debugPrint('Error: $error');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
      debugPrint('========================================');

      // ------------------------------------------------------
      // DETERMINE ERROR TYPE
      // ------------------------------------------------------

      final errorText = error.toString().toLowerCase();

      String errorMessage;

      // Gemini / API quota error
      if (errorText.contains('quota') ||
          errorText.contains('429') ||
          errorText.contains('rate limit') ||
          errorText.contains('resource exhausted')) {
        errorMessage =
            'AI usage limit reached. Please wait a few seconds '
            'and try again.';
      }
      // Network related error
      else if (errorText.contains('network') ||
          errorText.contains('socket') ||
          errorText.contains('connection')) {
        errorMessage =
            'Unable to connect to GreenMind AI. '
            'Please check your internet connection and try again.';
      }
      // Generic error
      else {
        errorMessage =
            'Unable to process your message. '
            'Please try again.';
      }

      // ------------------------------------------------------
      // UPDATE ERROR STATE
      // ------------------------------------------------------

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  // ----------------------------------------------------------
  // CLEAR CHAT
  // ----------------------------------------------------------

  void clearChat() {
    state = ChatbotState(
      messages: [_createWelcomeMessage()],
      isLoading: false,
      errorMessage: null,
    );
  }
}

// ============================================================
// CHATBOT STATE
// ============================================================

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  // ----------------------------------------------------------
  // COPY WITH
  // ----------------------------------------------------------

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
