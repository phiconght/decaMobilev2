import 'package:deca_mobile/core/theme/app_theme.dart';
import 'package:deca_mobile/exams/data/exam_taking_repository.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';
import 'package:deca_mobile/exams/data/models/exam_paper.dart';
import 'package:deca_mobile/exams/data/models/exam_question.dart';
import 'package:deca_mobile/exams/view/exam_paper_page.dart';
import 'package:deca_mobile/exams/widgets/question_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repo gia trong test: id chan = dang lam, id le = da nop (chi xem).
class _FakeExamTakingRepository implements ExamTakingRepository {
  const _FakeExamTakingRepository();

  static const _questions = [
    ExamQuestion(
      examExerciseId: 101,
      exerciseId: 1,
      type: QuestionType.multipleChoice,
      points: 2,
      questionText: 'Câu trắc nghiệm?',
      options: [
        QuestionOption(id: 1001, order: 0, text: 'A sai'),
        QuestionOption(id: 1002, order: 1, text: 'B đúng', isCorrect: true),
      ],
    ),
    ExamQuestion(
      examExerciseId: 102,
      exerciseId: 2,
      type: QuestionType.essay,
      points: 3,
      questionText: 'Câu tự luận?',
    ),
  ];

  @override
  Future<ExamPaper> fetchPaper(int examId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final done = examId.isOdd;
    if (!done) {
      return ExamPaper(
        examId: examId,
        code: 'D1',
        name: 'Kiểm tra',
        durationMinutes: 45,
        deadline: DateTime.now().add(const Duration(minutes: 45)),
        status: AttemptStatus.dangKiemTra,
        questions: _questions,
      );
    }
    const submitted = ExamAnswers(mc: {101: 1002}, essay: {102: 'Bài làm'});
    return ExamPaper(
      examId: examId,
      code: 'D1',
      name: 'Kiểm tra',
      durationMinutes: 45,
      status: AttemptStatus.daLam,
      questions: _questions,
      submitted: submitted,
      score: 2,
    );
  }

  @override
  Future<ExamResult> submit({
    required ExamPaper paper,
    required ExamAnswers answers,
  }) async =>
      gradeExam(paper, answers);

  @override
  Future<void> saveDraft({
    required int examId,
    required ExamAnswers answers,
  }) async {}
}

// Dung AppTheme THAT (khong dung theme mac dinh cua MaterialApp) de test
// bat duoc loi layout do theme gay ra — vd min-width vo han cua button
// tung lam trang body man lam bai (BoxConstraints forces an infinite width).
Widget _wrap(int examId) => RepositoryProvider<ExamTakingRepository>(
      create: (_) => const _FakeExamTakingRepository(),
      child: MaterialApp(
        theme: AppTheme.light,
        home: ExamPaperPage(
          exam: Exam(
            id: examId,
            code: 'D1',
            name: 'Kiểm tra',
            type: 'BY_CLASS',
            status: 'ACTIVE',
          ),
        ),
      ),
    );

void main() {
  testWidgets('id chẵn (đang làm): render câu hỏi + có Thoát/Lưu/Nộp',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(2));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);

    expect(find.byType(QuestionCard), findsWidgets, reason: 'phải có câu hỏi');
    expect(find.text('Thoát'), findsWidgets);
    expect(find.text('Lưu'), findsWidgets);
    expect(find.text('Nộp bài'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('id lẻ (đã làm): render read-only + kết quả', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    // Khong duoc tran layout (RenderFlex overflow) tren man hep.
    expect(tester.takeException(), isNull);

    expect(find.byType(QuestionCard), findsWidgets);
    expect(find.text('Đã nộp bài'), findsWidgets);
  });

  testWidgets('bấm Thoát (đang làm) hiện dialog xác nhận', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.text('Thoát').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Thoát khỏi bài làm'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
