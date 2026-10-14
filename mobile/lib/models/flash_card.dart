class FlashCard {
  FlashCard({
    required this.id,
    required this.question,
    required this.answer,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String question;
  final String answer;
  final String? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      folderId: json['folderId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
