/// Dang cau hoi — khop ExerciseType cua BE.
enum QuestionType { multipleChoice, essay, trueFalse }

QuestionType questionTypeFromString(String? s) => switch (s) {
      'ESSAY' => QuestionType.essay,
      'TRUE_FALSE' => QuestionType.trueFalse,
      _ => QuestionType.multipleChoice,
    };

/// Mot phuong an trac nghiem — khop ChoiceOptionResponse.
class QuestionOption {
  const QuestionOption({
    required this.id,
    required this.order,
    this.isCorrect = false,
    this.text,
    this.image,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) => QuestionOption(
        id: (json['id'] as num).toInt(),
        order: (json['order'] as num?)?.toInt() ?? 0,
        text: json['text'] as String?,
        image: json['image'] as String?,
        isCorrect: (json['isCorrect'] as bool?) ?? false,
      );

  final int id;
  final int order;
  final String? text;
  final String? image;

  /// Chi dung de cham diem sau khi nop — KHONG hien thi luc dang lam.
  final bool isCorrect;
}

/// Mot y dung/sai — khop TrueFalseItemResponse.
class TfItem {
  const TfItem({
    required this.id,
    required this.order,
    required this.answer,
    this.text,
    this.image,
  });

  factory TfItem.fromJson(Map<String, dynamic> json) => TfItem(
        id: (json['id'] as num).toInt(),
        order: (json['order'] as num?)?.toInt() ?? 0,
        text: json['text'] as String?,
        image: json['image'] as String?,
        answer: (json['answer'] as bool?) ?? false,
      );

  final int id;
  final int order;
  final String? text;
  final String? image;

  /// Dap an dung (Dung/Sai) — chi dung cham diem sau khi nop.
  final bool answer;
}

/// Mot cau hoi trong de thi (gop ExamExercise + noi dung Exercise + diem).
class ExamQuestion {
  const ExamQuestion({
    required this.examExerciseId,
    required this.exerciseId,
    required this.type,
    required this.points,
    this.questionText,
    this.questionImage,
    this.options = const [],
    this.tfItems = const [],
    this.essayAnswer,
    this.essayAnswerImage,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) => ExamQuestion(
        examExerciseId: (json['examExerciseId'] as num).toInt(),
        exerciseId: (json['exerciseId'] as num).toInt(),
        type: questionTypeFromString(json['type'] as String?),
        points: (json['points'] as num?)?.toDouble() ?? 0,
        questionText: json['questionText'] as String?,
        questionImage: json['questionImage'] as String?,
        options: ((json['options'] as List?) ?? const [])
            .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        tfItems: ((json['trueFalseItems'] as List?) ?? const [])
            .map((e) => TfItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        essayAnswer: json['essayAnswer'] as String?,
        essayAnswerImage: json['essayAnswerImage'] as String?,
      );

  final int examExerciseId;
  final int exerciseId;
  final QuestionType type;
  final double points;
  final String? questionText;
  final String? questionImage;
  final List<QuestionOption> options;
  final List<TfItem> tfItems;

  /// Dap an goi y cho cau tu luan — chi hien sau khi nop.
  final String? essayAnswer;
  final String? essayAnswerImage;
}
