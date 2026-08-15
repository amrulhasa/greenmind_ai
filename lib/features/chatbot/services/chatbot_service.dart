import 'package:firebase_ai/firebase_ai.dart';
import 'package:logger/logger.dart';

class ChatbotService {
  final Logger _logger = Logger();

  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatbotService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash-lite',
      systemInstruction: Content.system(
        '''
You are GreenMind AI, an expert plant care assistant.

Your job is to help users with:
- Plant identification
- Plant care
- Watering
- Sunlight
- Soil
- Fertilizer
- Plant diseases
- Symptoms
- Treatment
- Prevention
- Indoor and outdoor gardening
- General plant health

Rules:
1. Give clear and practical answers.
2. Keep answers easy to understand.
3. If the user asks about a plant disease, explain possible causes,
   symptoms, treatment, and prevention when appropriate.
4. Do not claim certainty when the information is uncertain.
5. If an image is provided in the future, carefully analyze the image.
6. Do not give dangerous or clearly harmful advice.
7. Stay focused on plants, gardening, and plant care.
8. If the question is unrelated to plants, politely explain that you
   are GreenMind AI and specialize in plant-related questions.
9. Do not use unnecessary markdown.
10. Be friendly and helpful.
        ''',
      ),
    );

    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      _logger.i('Sending message to GreenMind AI');

      final response = await _chat.sendMessage(
        Content.text(message),
      );

      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw Exception('AI returned an empty response.');
      }

      _logger.i('AI response received');

      return text.trim();
    } on QuotaExceeded catch (error, stackTrace) {
      _logger.e(
        'Gemini quota exceeded',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception(
        'AI usage limit reached. Please wait a little and try again.',
      );
    } on InvalidApiKey catch (error, stackTrace) {
      _logger.e(
        'Invalid Gemini API key',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception(
        'GreenMind AI configuration error. Please check the Firebase API configuration.',
      );
    } on ServerException catch (error, stackTrace) {
      _logger.e(
        'Gemini server error',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception(
        'GreenMind AI server is temporarily unavailable. Please try again later.',
      );
    } on FirebaseAIException catch (error, stackTrace) {
      _logger.e(
        'Firebase AI error',
        error: error,
        stackTrace: stackTrace,
      );

      final errorText = error.toString().toLowerCase();

      if (errorText.contains('quota') ||
          errorText.contains('429') ||
          errorText.contains('rate limit') ||
          errorText.contains('resource exhausted')) {
        throw Exception(
          'AI usage limit reached. Please wait a little and try again.',
        );
      }

      throw Exception(
        'GreenMind AI could not process your request. Please try again.',
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Unexpected chatbot error',
        error: error,
        stackTrace: stackTrace,
      );

      final errorText = error.toString().toLowerCase();

      if (errorText.contains('quota') ||
          errorText.contains('429') ||
          errorText.contains('rate limit') ||
          errorText.contains('resource exhausted')) {
        throw Exception(
          'AI usage limit reached. Please wait a little and try again.',
        );
      }

      if (errorText.contains('network') ||
          errorText.contains('connection') ||
          errorText.contains('socket')) {
        throw Exception(
          'Unable to connect to GreenMind AI. Please check your internet connection.',
        );
      }

      throw Exception(
        'Unable to get a response from GreenMind AI. Please try again.',
      );
    }
  }
}