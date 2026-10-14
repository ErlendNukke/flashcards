import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/services/api_client.dart';

class CardService {
  CardService(this._api);

  final ApiClient _api;

  Future<List<FlashCard>> listCards({String? folderId, bool unfiledOnly = false}) async {
    final query = <String, String>{};
    if (unfiledOnly) {
      query['unfiled'] = 'true';
    } else if (folderId != null) {
      query['folderId'] = folderId;
    }
    final path = query.isEmpty ? '/api/cards' : '/api/cards?${_encodeQuery(query)}';
    final json = await _api.request<List<dynamic>>('GET', path);
    return json.map((e) => FlashCard.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FlashCard> createCard({
    required String question,
    required String answer,
    String? folderId,
  }) async {
    final json = await _api.request<Map<String, dynamic>>(
      'POST',
      '/api/cards',
      body: {
        'question': question,
        'answer': answer,
        'folderId': folderId,
      },
      parser: (v) => v as Map<String, dynamic>,
    );
    return FlashCard.fromJson(json);
  }

  Future<FlashCard> updateCard({
    required String id,
    required String question,
    required String answer,
    String? folderId,
  }) async {
    final json = await _api.request<Map<String, dynamic>>(
      'PUT',
      '/api/cards/$id',
      body: {
        'question': question,
        'answer': answer,
        'folderId': folderId,
      },
      parser: (v) => v as Map<String, dynamic>,
    );
    return FlashCard.fromJson(json);
  }

  Future<void> deleteCard(String id) async {
    await _api.request<void>('DELETE', '/api/cards/$id');
  }

  Future<int> bulkDelete(List<String> ids) async {
    final json = await _api.request<Map<String, dynamic>>(
      'POST',
      '/api/cards/bulk-delete',
      body: {'ids': ids},
      parser: (v) => v as Map<String, dynamic>,
    );
    return (json['affected'] as num).toInt();
  }

  Future<int> bulkMove({required List<String> ids, String? folderId}) async {
    final json = await _api.request<Map<String, dynamic>>(
      'POST',
      '/api/cards/bulk-move',
      body: {'ids': ids, 'folderId': folderId},
      parser: (v) => v as Map<String, dynamic>,
    );
    return (json['affected'] as num).toInt();
  }

  String _encodeQuery(Map<String, String> query) {
    return query.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
  }
}
