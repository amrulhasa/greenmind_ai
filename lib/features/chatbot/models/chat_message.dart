enum ChatMessageRole {
  user,
  assistant,
}

class ChatMessage {
  final String id;
  final String text;
  final ChatMessageRole role;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
  });

  bool get isUser => role == ChatMessageRole.user;

  bool get isAssistant => role == ChatMessageRole.assistant;
}