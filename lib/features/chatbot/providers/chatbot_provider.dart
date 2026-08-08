import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../services/chatbot_service.dart';

final chatbotServiceProvider = Provider<ChatbotService>(
  (ref) => ChatbotService(),
);

final chatbotProvider =
    NotifierProvider<ChatbotNotifier, ChatbotState>(
  ChatbotNotifier.new,
);

class ChatbotNotifier extends Notifier<ChatbotState> {
  final Uuid _uuid = const Uuid();

  ChatbotService get _service {
    return ref.read(chatbotServiceProvider);
  }

  @override
  ChatbotState build() {
    return ChatbotState(
      messages: [
        ChatMessage(
          id: _uuid.v4(),
          text:
              'Hello! I am GreenMind AI. Ask me anything about your plants.',
          role: ChatMessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    final message = text.trim();

    if (message.isEmpty || state.isLoading) {
      return;
    }

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: message,
      role: ChatMessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [
        ...state.messages,
        userMessage,
      ],
      isLoading: true,
      errorMessage: null,
    );

    try {
      final response = await _service.sendMessage(message);

      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        text: response,
        role: ChatMessageRole.assistant,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [
          ...state.messages,
          assistantMessage,
        ],
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to process your message.',
      );
    }
  }

  void clearChat() {
    state = ChatbotState(
      messages: [
        ChatMessage(
          id: _uuid.v4(),
          text:
              'Hello! I am GreenMind AI. Ask me anything about your plants.',
          role: ChatMessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

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