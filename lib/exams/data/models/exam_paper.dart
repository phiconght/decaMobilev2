import 'package:deca_mobile/exams/data/models/exam_question.dart';

/// Trang thai lam bai cua hoc vien voi de — khop ExamStudentStatus (+ QUA_HAN).
enum AttemptStatus { daPhatHanh, dangKiemTra, daLam, quaHan }

// TODO(be): CHUA_PHAT_HANH/DA_XOA dang roi vao daPhatHanh (cho lam). Khi noi
// BE, chan o load() hoac them trang thai khong-cho-lam (ly tuong: /paper chan).
AttemptStatus attemptStatusFromString(String? s) => switch (s) {
      'DANG_KIEM_TRA' => AttemptStatus.dangKiemTra,
      'DA_LAM' => AttemptStatus.daLam,
      'QUA_HAN' => AttemptStatus.quaHan,
      _ => AttemptStatus.daPhatHanh,
    };

/// Da nop (DA_LAM) hoac qua han (QUA_HAN) -> chi xem, khong sua duoc.
bool isReadOnlyStatus(AttemptStatus s) =>
    s == AttemptStatus.daLam || s == AttemptStatus.quaHan;

/// Dinh dang diem: bo '.0', toi da 2 chu so thap phan, bo so 0 thua.
String formatPoints(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  final s = value.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// Tap cau tra loi cua hoc vien.
class ExamAnswers {
  const ExamAnswers({
    this.mc = const {},
    this.tf = const {},
    this.essay = const {},
  });

  /// Parse tu JSON cua BE (key la chuoi so — Map JSON khong co key int).
  factory ExamAnswers.fromJson(Map<String, dynamic> json) => ExamAnswers(
        mc: {
          for (final e in ((json['mc'] as Map?) ?? const {}).entries)
            int.parse(e.key as String): (e.value as num).toInt(),
        },
        tf: {
          for (final e in ((json['tf'] as Map?) ?? const {}).entries)
            int.parse(e.key as String): {
              for (final i in (e.value as Map).entries)
                int.parse(i.key as String): i.value as bool,
            },
        },
        essay: {
          for (final e in ((json['essay'] as Map?) ?? const {}).entries)
            int.parse(e.key as String): e.value as String,
        },
      );

  /// examExerciseId -> optionId da chon.
  final Map<int, int> mc;

  /// examExerciseId -> { tfItemId -> Dung/Sai }.
  final Map<int, Map<int, bool>> tf;

  /// examExerciseId -> noi dung tu luan.
  final Map<int, String> essay;

  Map<String, dynamic> toJson() => {
        'mc': mc.map((k, v) => MapEntry('$k', v)),
        'tf': tf.map(
          (k, v) => MapEntry('$k', v.map((k2, v2) => MapEntry('$k2', v2))),
        ),
        'essay': essay.map((k, v) => MapEntry('$k', v)),
      };
}

/// Mot de thi day du de lam bai.
class ExamPaper {
  const ExamPaper({
    required this.examId,
    required this.code,
    required this.name,
    required this.status,
    required this.questions,
    this.durationMinutes,
    this.deadline,
    this.submitted,
    this.score,
    this.result,
  });

  /// Khop `ExamPaperResponse` cua BE (GET /api/v1/exams/{id}/paper).
  factory ExamPaper.fromJson(Map<String, dynamic> json) => ExamPaper(
        examId: (json['examId'] as num).toInt(),
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String).toLocal(),
        status: attemptStatusFromString(json['status'] as String?),
        questions: ((json['questions'] as List?) ?? const [])
            .map((e) => ExamQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        submitted: json['submitted'] == null
            ? null
            : ExamAnswers.fromJson(json['submitted'] as Map<String, dynamic>),
        score: (json['score'] as num?)?.toDouble(),
        result: json['result'] == null
            ? null
            : ExamResult.fromJson(json['result'] as Map<String, dynamic>),
      );

  final int examId;
  final String code;
  final String name;
  final int? durationMinutes;

  /// Moc het gio (mock: now + duration; BE: min(startedAt+duration, endAt)).
  final DateTime? deadline;
  final AttemptStatus status;
  final List<ExamQuestion> questions;

  /// Cau tra loi da nop (chi co khi status = DA_LAM, dung de hien lai).
  final ExamAnswers? submitted;

  /// Diem da cham (neu co).
  final double? score;

  /// Ket qua cham tu BE (nguon chinh thuc khi da nop / qua han).
  final ExamResult? result;

  bool get isReadOnly => isReadOnlyStatus(status);

  double get totalPoints =>
      questions.fold<double>(0, (sum, q) => sum + q.points);
}

/// Ket qua cham 1 cau.
class QuestionResult {
  const QuestionResult({
    required this.earned,
    required this.max,
    this.correct,
  });

  final double earned;
  final double max;

  /// true/false cho cau tu cham (MC/TF); null = cau tu luan (cham tay).
  final bool? correct;
}

/// Ket qua cham toan bai.
class ExamResult {
  const ExamResult({
    required this.earned,
    required this.total,
    required this.autoCorrect,
    required this.autoTotal,
    required this.hasEssay,
    required this.byQuestion,
  });

  /// Khop `ExamGradeResponse` cua BE.
  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
        earned: (json['earned'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        autoCorrect: (json['autoCorrect'] as num?)?.toInt() ?? 0,
        autoTotal: (json['autoTotal'] as num?)?.toInt() ?? 0,
        hasEssay: json['hasEssay'] as bool? ?? false,
        byQuestion: {
          for (final q in (json['byQuestion'] as List?) ?? const [])
            ((q as Map<String, dynamic>)['examExerciseId'] as num).toInt():
                QuestionResult(
              earned: (q['earned'] as num?)?.toDouble() ?? 0,
              max: (q['max'] as num?)?.toDouble() ?? 0,
              correct: q['correct'] as bool?,
            ),
        },
      );

  final double earned;
  final double total;
  final int autoCorrect;
  final int autoTotal;
  final bool hasEssay;
  final Map<int, QuestionResult> byQuestion;
}

/// Cham bai: MC/TF tu cham theo dap an, tu luan de cham tay (earned 0, correct null).
/// TF cham theo ti le y dung; "dung ca cau" khi tat ca y khop.
ExamResult gradeExam(ExamPaper paper, ExamAnswers answers) {
  final byQuestion = <int, QuestionResult>{};
  var earned = 0.0;
  var autoCorrect = 0;
  var autoTotal = 0;
  var hasEssay = false;

  for (final q in paper.questions) {
    switch (q.type) {
      case QuestionType.multipleChoice:
        autoTotal++;
        final picked = answers.mc[q.examExerciseId];
        final correct = picked != null &&
            q.options.any((o) => o.id == picked && o.isCorrect);
        final gained = correct ? q.points : 0.0;
        earned += gained;
        if (correct) autoCorrect++;
        byQuestion[q.examExerciseId] =
            QuestionResult(earned: gained, max: q.points, correct: correct);
      case QuestionType.trueFalse:
        autoTotal++;
        final picks = answers.tf[q.examExerciseId] ?? const {};
        final total = q.tfItems.length;
        final right = total == 0
            ? 0
            : q.tfItems.where((it) => picks[it.id] == it.answer).length;
        final allRight = total > 0 && right == total;
        final gained = total == 0 ? 0.0 : q.points * right / total;
        earned += gained;
        if (allRight) autoCorrect++;
        byQuestion[q.examExerciseId] =
            QuestionResult(earned: gained, max: q.points, correct: allRight);
      case QuestionType.essay:
        hasEssay = true;
        byQuestion[q.examExerciseId] =
            QuestionResult(earned: 0, max: q.points);
    }
  }

  return ExamResult(
    earned: earned,
    total: paper.totalPoints,
    autoCorrect: autoCorrect,
    autoTotal: autoTotal,
    hasEssay: hasEssay,
    byQuestion: byQuestion,
  );
}
