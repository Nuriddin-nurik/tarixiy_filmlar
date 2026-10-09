class CommentModel {
  final int id;
  final String authorName;
  final String text;
  final DateTime createdAt;
  final bool mine;

  const CommentModel({
    required this.id,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.mine = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: (json['id'] as num).toInt(),
      authorName: (json['authorName'] as String?)?.trim() ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      mine: json['mine'] as bool? ?? false,
    );
  }
}

class CommentPageModel {
  final List<CommentModel> items;
  final bool hasMore;
  final int total;

  const CommentPageModel({required this.items, required this.hasMore, required this.total});

  factory CommentPageModel.fromJson(Map<String, dynamic> json) {
    return CommentPageModel(
      items: ((json['items'] as List?) ?? const [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}
