/// Mot dong bai viet trong feed (khong kem content day du).
class PostItem {
  const PostItem({
    required this.id,
    required this.title,
    this.summary,
    this.coverImageUrl,
    this.pinned = false,
    this.publishedAt,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      summary: json['summary'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      pinned: (json['pinned'] as bool?) ?? false,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.tryParse(json['publishedAt'] as String),
    );
  }

  final int id;
  final String title;
  final String? summary;
  final String? coverImageUrl;
  final bool pinned;
  final DateTime? publishedAt;
}
