import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/services/api_client.dart';

class CardService {
  CardService(this._api);

  final ApiClient _api;

  Future<List<FlashCard>> listCards() async {
    final json = await _api.request<List<dynamic>>('GET', '/api/cards');
    return json.map((e) => FlashCard.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FlashCard> createCard({required String question, required String answer}) async {
    final json = await _api.request<Map<String, dynamic>>(
      'POST',
      '/api/cards',
      body: {'question': question, 'answer': answer},
      parser: (v) => v as Map<String, dynamic>,
    );
    return FlashCard.fromJson(json);
  }

  Future<FlashCard> updateCard({
    required String id,
    required String question,
    required String answer,
  }) async {
    final json = await _api.request<Map<String, dynamic>>(
      'PUT',
      '/api/cards/$id',
      body: {'question': question, 'answer': answer},
      parser: (v) => v as Map<String, dynamic>,
    );
    return FlashCard.fromJson(json);
  }

  Future<void> deleteCard(String id) async {
    await _api.request<void>('DELETE', '/api/cards/$id');
  }
}
