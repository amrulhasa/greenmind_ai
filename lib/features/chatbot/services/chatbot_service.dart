import 'package:logger/logger.dart';

class ChatbotService {
  final Logger _logger = Logger();

  Future<String> sendMessage(String message) async {
    _logger.i('Processing chatbot message');

    await Future.delayed(
      const Duration(seconds: 1),
    );

    final text = message.toLowerCase();

    if (text.contains('water')) {
      return 'Most plants prefer watering when the top layer of soil feels dry. '
          'Avoid overwatering because it can damage the roots.';
    }

    if (text.contains('yellow')) {
      return 'Yellow leaves can have several causes, including overwatering, '
          'poor drainage, insufficient light, or nutrient deficiency.';
    }

    if (text.contains('disease')) {
      return 'I can help you understand common plant diseases. '
          'For a more accurate diagnosis, upload a clear image of the affected leaf.';
    }

    if (text.contains('fertilizer')) {
      return 'Use a fertilizer appropriate for your plant type and follow the '
          'recommended dosage. Avoid excessive fertilizer application.';
    }

    return 'I am your GreenMind AI plant assistant. '
        'Ask me about plant care, watering, diseases, sunlight, soil, or fertilizer.';
  }
}