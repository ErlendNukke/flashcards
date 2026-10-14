class StudyFolder {
  StudyFolder({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int cardCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory StudyFolder.fromJson(Map<String, dynamic> json) {
    return StudyFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      cardCount: (json['cardCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class LibrarySummary {
  LibrarySummary({required this.folders, required this.unfiledCount});

  final List<StudyFolder> folders;
  final int unfiledCount;

  factory LibrarySummary.fromJson(Map<String, dynamic> json) {
    final foldersJson = json['folders'] as List<dynamic>;
    return LibrarySummary(
      folders: foldersJson.map((e) => StudyFolder.fromJson(e as Map<String, dynamic>)).toList(),
      unfiledCount: (json['unfiledCount'] as num).toInt(),
    );
  }
}
