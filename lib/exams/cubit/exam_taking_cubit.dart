import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/exams/data/exam_taking_repository.dart';
import 'package:deca_mobile/exams/data/models/exam_paper.dart';
import 'package:deca_mobile/exams/data/models/exam_question.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamTakingState extends Equatable {
  const ExamTakingState({
    this.status = ViewStatus.initial,
    this.paper,
    this.readOnly = false,
    this.submitting = false,
    this.saving = false,
    this.mc = const {},
    this.tf = const {},
    this.essay = const {},
    this.result,
    this.error,
  });

  final ViewStatus status;
  final ExamPaper? paper;
  final bool readOnly;
  final bool submitting;
  final bool saving;
  final Map<int, int> mc;
  final Map<int, Map<int, bool>> tf;
  final Map<int, String> essay;
  final ExamResult? result;
  final String? error;

  bool get isLoading => status == ViewStatus.loading;
  bool get isFailure => status == ViewStatus.failure;

  int get totalCount => paper?.questions.length ?? 0;

  /// Mot cau da tra loi chua (MC da chon · TF du moi y · tu luan khac rong).
  bool isAnswered(ExamQuestion q) {
    switch (q.type) {
      case QuestionType.multipleChoice:
        return mc[q.examExerciseId] != null;
      case QuestionType.trueFalse:
        final picks = tf[q.examExerciseId];
        return picks != null &&
            q.tfItems.isNotEmpty &&
            q.tfItems.every((it) => picks[it.id] != null);
      case QuestionType.essay:
        return (essay[q.examExerciseId] ?? '').trim().isNotEmpty;
    }
  }

  /// So cau da tra loi.
  int get answeredCount => paper?.questions.where(isAnswered).length ?? 0;

  ExamTakingState copyWith({
    ViewStatus? status,
    ExamPaper? paper,
    bool? readOnly,
    bool? submitting,
    bool? saving,
    Map<int, int>? mc,
    Map<int, Map<int, bool>>? tf,
    Map<int, String>? essay,
    ExamResult? result,
    String? error,
  }) {
    return ExamTakingState(
      status: status ?? this.status,
      paper: paper ?? this.paper,
      readOnly: readOnly ?? this.readOnly,
      submitting: submitting ?? this.submitting,
      saving: saving ?? this.saving,
      mc: mc ?? this.mc,
      tf: tf ?? this.tf,
      essay: essay ?? this.essay,
      result: result ?? this.result,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        paper,
        readOnly,
        submitting,
        saving,
        mc,
        tf,
        essay,
        result,
        error,
      ];
}

class ExamTakingCubit extends Cubit<ExamTakingState> {
  ExamTakingCubit(this._repo, this._examId) : super(const ExamTakingState());

  final ExamTakingRepository _repo;
  final int _examId;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final paper = await _repo.fetchPaper(_examId);
      if (paper.isReadOnly) {
        final answers = paper.submitted ?? const ExamAnswers();
        emit(
          ExamTakingState(
            status: ViewStatus.success,
            paper: paper,
            readOnly: true,
            mc: answers.mc,
            tf: answers.tf,
            essay: answers.essay,
            // Ket qua cham lay tu BE (nguon chinh thuc); fallback cham
            // client cho du lieu cu khong co result.
            result: paper.result ?? gradeExam(paper, answers),
          ),
        );
      } else {
        // Dang lam: khoi phuc ban nhap da luu (neu co) de lam tiep.
        final draft = paper.submitted;
        emit(
          ExamTakingState(
            status: ViewStatus.success,
            paper: paper,
            mc: draft?.mc ?? const {},
            tf: draft?.tf ?? const {},
            essay: draft?.essay ?? const {},
          ),
        );
      }
    } on ApiException catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, error: e.message));
    } on Object {
      emit(
        state.copyWith(status: ViewStatus.failure, error: 'Đã có lỗi xảy ra'),
      );
    }
  }

  void selectOption(int questionId, int optionId) {
    if (state.readOnly) return;
    emit(state.copyWith(mc: {...state.mc, questionId: optionId}));
  }

  // bool Dung/Sai de positional cho closure goi gon (named gay loi suy luan).
  // ignore: avoid_positional_boolean_parameters
  void setTfAnswer(int questionId, int itemId, bool value) {
    if (state.readOnly) return;
    final next = {
      for (final entry in state.tf.entries) entry.key: {...entry.value},
    };
    (next[questionId] ??= {})[itemId] = value;
    emit(state.copyWith(tf: next));
  }

  void setEssay(int questionId, String text) {
    if (state.readOnly) return;
    emit(state.copyWith(essay: {...state.essay, questionId: text}));
  }

  /// Luu nhap bai dang lam (giu tien do). No-op khi da nop / dang luu.
  Future<void> saveDraft() async {
    final paper = state.paper;
    if (paper == null || state.readOnly || state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final answers =
          ExamAnswers(mc: state.mc, tf: state.tf, essay: state.essay);
      await _repo.saveDraft(examId: paper.examId, answers: answers);
      emit(state.copyWith(saving: false));
    } on ApiException catch (e) {
      emit(state.copyWith(saving: false, error: e.message));
    } on Object {
      emit(state.copyWith(saving: false, error: 'Lưu thất bại'));
    }
  }

  Future<void> submit() async {
    final paper = state.paper;
    if (paper == null || state.readOnly || state.submitting) return;
    emit(state.copyWith(submitting: true));
    try {
      final answers =
          ExamAnswers(mc: state.mc, tf: state.tf, essay: state.essay);
      final result = await _repo.submit(paper: paper, answers: answers);
      // Tai lai de sau khi nop: BE luc nay moi lo dap an dung (isCorrect,
      // answer, essayAnswer) de man review to mau va hien dap an goi y.
      var reviewPaper = paper;
      try {
        reviewPaper = await _repo.fetchPaper(paper.examId);
      } on Object {
        // Khong tai duoc ban review: giu de cu, van hien diem tu `result`.
      }
      emit(
        state.copyWith(
          submitting: false,
          readOnly: true,
          paper: reviewPaper,
          result: reviewPaper.result ?? result,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
    } on Object {
      emit(state.copyWith(submitting: false, error: 'Nộp bài thất bại'));
    }
  }
}
