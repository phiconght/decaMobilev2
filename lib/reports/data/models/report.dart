/// Ket qua mot bai lam cua hoc sinh (bao cao hoc tap).
class Report {
  const Report({
    required this.examCode,
    required this.examName,
    required this.subjectName,
    required this.score,
    required this.maxScore,
    required this.submittedAt,
    this.multipleChoiceScore,
    this.essayScore,
    this.durationMinutes,
    this.comment,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        examCode: json['examCode'] as String,
        examName: json['examName'] as String,
        subjectName: json['subjectName'] as String,
        score: (json['score'] as num).toDouble(),
        maxScore: (json['maxScore'] as num).toDouble(),
        submittedAt: DateTime.parse(json['submittedAt'] as String),
        multipleChoiceScore: (json['multipleChoiceScore'] as num?)?.toDouble(),
        essayScore: (json['essayScore'] as num?)?.toDouble(),
        durationMinutes: json['durationMinutes'] as int?,
        comment: json['comment'] as String?,
      );

  final String examCode;
  final String examName;
  final String subjectName;
  final double score;
  final double maxScore;
  final DateTime submittedAt;
  final double? multipleChoiceScore;
  final double? essayScore;
  final int? durationMinutes;
  final String? comment;

  /// Ti le diem 0..1 (de chon mau hien thi).
  double get ratio => maxScore == 0 ? 0 : score / maxScore;
}
