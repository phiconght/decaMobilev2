/// Chi tiet bai viet (kem content_md day du).
class PostDetail {
  const PostDetail({
    required this.id,
    required this.title,
    required this.contentMd,
    this.summary,
    this.coverImageUrl,
    this.publishedAt,
    this.author,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    return PostDetail(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      contentMd: (json['contentMd'] as String?) ?? '',
      summary: json['summary'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.tryParse(json['publishedAt'] as String),
      author: json['author'] as String?,
    );
  }

  final int id;
  final String title;
  final String contentMd;
  final String? summary;
  final String? coverImageUrl;
  final DateTime? publishedAt;
  final String? author;
}
