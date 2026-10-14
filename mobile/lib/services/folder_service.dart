import 'package:flashcards/models/folder.dart';
import 'package:flashcards/services/api_client.dart';

class FolderService {
  FolderService(this._api);

  final ApiClient _api;

  Future<LibrarySummary> fetchLibrary() async {
    final json = await _api.request<Map<String, dynamic>>(
      'GET',
      '/api/folders',
      parser: (v) => v as Map<String, dynamic>,
    );
    return LibrarySummary.fromJson(json);
  }

  Future<StudyFolder> createFolder(String name) async {
    final json = await _api.request<Map<String, dynamic>>(
      'POST',
      '/api/folders',
      body: {'name': name},
      parser: (v) => v as Map<String, dynamic>,
    );
    return StudyFolder.fromJson(json);
  }

  Future<StudyFolder> renameFolder({required String id, required String name}) async {
    final json = await _api.request<Map<String, dynamic>>(
      'PUT',
      '/api/folders/$id',
      body: {'name': name},
      parser: (v) => v as Map<String, dynamic>,
    );
    return StudyFolder.fromJson(json);
  }

  Future<void> deleteFolder(String id) async {
    await _api.request<void>('DELETE', '/api/folders/$id');
  }
}
