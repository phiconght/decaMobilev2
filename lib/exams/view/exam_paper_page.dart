import 'dart:async';

import 'package:deca_mobile/core/state/view_status.dart';
import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/core/widgets/app_dialogs.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_snackbar.dart';
import 'package:deca_mobile/core/widgets/primary_button.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/exams/cubit/exam_taking_cubit.dart';
import 'package:deca_mobile/exams/data/exam_pdf_saver.dart';
import 'package:deca_mobile/exams/data/exam_taking_repository.dart';
import 'package:deca_mobile/exams/data/exams_repository.dart';
import 'package:deca_mobile/exams/data/models/exam.dart';
import 'package:deca_mobile/exams/widgets/countdown_timer.dart';
import 'package:deca_mobile/exams/widgets/exam_result_header.dart';
import 'package:deca_mobile/exams/widgets/question_card.dart';
import 'package:deca_mobile/exams/widgets/question_jump_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Màn làm bài — dùng chung cho bài đang làm và bài đã làm (chỉ xem).
class ExamPaperPage extends StatelessWidget {
  const ExamPaperPage({required this.exam, super.key});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit =
            ExamTakingCubit(ctx.read<ExamTakingRepository>(), exam.id);
        unawaited(cubit.load());
        return cubit;
      },
      child: _ExamPaperView(exam: exam),
    );
  }
}

class _ExamPaperView extends StatefulWidget {
  const _ExamPaperView({required this.exam});

  final Exam exam;

  @override
  State<_ExamPaperView> createState() => _ExamPaperViewState();
}

class _ExamPaperViewState extends State<_ExamPaperView> {
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _keys = {};

  GlobalKey _keyFor(int index) => _keys.putIfAbsent(index, GlobalKey.new);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _confirmSubmit(
    BuildContext context,
    ExamTakingState state,
  ) async {
    final cubit = context.read<ExamTakingCubit>();
    final remaining = state.totalCount - state.answeredCount;
    final ok = await AppDialogs.confirm(
      context,
      title: 'Nộp bài',
      message: remaining > 0
          ? 'Còn $remaining câu chưa làm. Bạn vẫn muốn nộp bài?'
          : 'Bạn chắc chắn muốn nộp bài?',
      confirmText: 'Nộp bài',
    );
    if (!ok) return;
    await cubit.submit();
  }

  void _autoSubmit(BuildContext context) {
    final cubit = context.read<ExamTakingCubit>();
    if (cubit.state.readOnly || cubit.state.submitting) return;
    unawaited(cubit.submit());
    AppSnackBar.info(context, 'Hết giờ — đã tự động nộp bài.');
  }

  /// Tai de thi PDF (bien the DE — khong dap an) va luu/mo theo nen tang.
  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes =
          await context.read<ExamsRepository>().examPdf(widget.exam.id);
      await savePdf(bytes, 'De-thi_${widget.exam.code}.pdf');
      if (context.mounted) {
        AppSnackBar.success(context, 'Đã tải đề thi PDF');
      }
    } on ApiException catch (e) {
      if (context.mounted) AppSnackBar.error(context, e.message);
    } on Object {
      if (context.mounted) {
        AppSnackBar.error(context, 'Tải file thất bại');
      }
    }
  }

  void _openJump(BuildContext context, ExamTakingState state) {
    final paper = state.paper;
    if (paper == null) return;
    final answered = <int>{
      for (var i = 0; i < paper.questions.length; i++)
        if (state.isAnswered(paper.questions[i])) i,
    };
    showQuestionJumpSheet(
      context,
      total: paper.questions.length,
      answered: answered,
      onSelect: (index) {
        final ctx = _keys[index]?.currentContext;
        if (ctx != null) {
          unawaited(
            Scrollable.ensureVisible(
              ctx,
              duration: AppDurations.normal,
              alignment: 0.05,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExamTakingCubit, ExamTakingState>(
      listenWhen: (prev, curr) =>
          curr.error != null &&
          curr.error != prev.error &&
          curr.status == ViewStatus.success &&
          curr.paper != null &&
          !curr.submitting,
      listener: (context, state) => AppSnackBar.error(context, state.error!),
      builder: (context, state) {
        final paper = state.paper;
        return PopScope(
          canPop: state.readOnly,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final navigator = Navigator.of(context);
            final ok = await _confirmExit(context);
            if (ok) navigator.pop();
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                widget.exam.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Tải đề PDF',
                  onPressed: () => unawaited(_downloadPdf(context)),
                ),
                if (paper != null &&
                    !state.readOnly &&
                    paper.deadline != null &&
                    paper.questions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Center(
                      child: CountdownTimer(
                        key: const ValueKey('exam-timer'),
                        deadline: paper.deadline!,
                        onExpire: () => _autoSubmit(context),
                      ),
                    ),
                  )
                else if (state.readOnly)
                  const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.md),
                    child: Center(child: _DonePill()),
                  ),
              ],
            ),
            body: Column(
              children: [
                _topBar(context, state),
                Expanded(child: _body(context, state)),
              ],
            ),
            bottomNavigationBar: _bottomBar(context, state),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, ExamTakingState state) {
    if (state.isLoading && state.paper == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isFailure && state.paper == null) {
      return AppErrorView(
        message: state.error ?? 'Đã có lỗi xảy ra',
        onRetry: context.read<ExamTakingCubit>().load,
      );
    }
    final paper = state.paper;
    if (paper == null || paper.questions.isEmpty) {
      return const AppEmptyView(message: 'Đề thi chưa có câu hỏi.');
    }

    final cubit = context.read<ExamTakingCubit>();
    return Column(
      children: [
        if (!state.readOnly)
          _ProgressStrip(
            answered: state.answeredCount,
            total: state.totalCount,
          ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (state.readOnly && state.result != null) ...[
                ExamResultHeader(result: state.result!),
                const SizedBox(height: AppSpacing.md),
              ],
              for (var i = 0; i < paper.questions.length; i++) ...[
                KeyedSubtree(
                  key: _keyFor(i),
                  child: QuestionCard(
                    index: i + 1,
                    question: paper.questions[i],
                    readOnly: state.readOnly,
                    selectedOptionId:
                        state.mc[paper.questions[i].examExerciseId],
                    tfPicks: state.tf[paper.questions[i].examExerciseId] ??
                        const <int, bool>{},
                    essayText:
                        state.essay[paper.questions[i].examExerciseId] ?? '',
                    result: state.result
                        ?.byQuestion[paper.questions[i].examExerciseId],
                    onSelectOption: (optionId) => cubit.selectOption(
                      paper.questions[i].examExerciseId,
                      optionId,
                    ),
                    onSetTf: (itemId, value) => cubit.setTfAnswer(
                      paper.questions[i].examExerciseId,
                      itemId,
                      value,
                    ),
                    onSetEssay: (text) => cubit.setEssay(
                      paper.questions[i].examExerciseId,
                      text,
                    ),
                  ),
                ),
                if (i < paper.questions.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Thanh hanh dong tren cung: Thoat + Luu (luon co) + nut nhay cau.
  Widget _topBar(BuildContext context, ExamTakingState state) {
    final theme = Theme.of(context);
    final paper = state.paper;
    final hasQuestions = paper != null && paper.questions.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            _exitButton(context),
            const SizedBox(width: AppSpacing.sm),
            _saveButton(context, state),
            const Spacer(),
            if (hasQuestions)
              TextButton.icon(
                onPressed: () => _openJump(context, state),
                icon: const Icon(Icons.grid_view_outlined),
                label: Text('${state.answeredCount}/${state.totalCount}'),
              ),
          ],
        ),
      ),
    );
  }

  /// Thanh hanh dong duoi cung: Thoat + Luu (luon co) + Nop bai.
  Widget _bottomBar(BuildContext context, ExamTakingState state) {
    final paper = state.paper;
    final canSubmit =
        paper != null && !state.readOnly && paper.questions.isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            _exitButton(context),
            const SizedBox(width: AppSpacing.sm),
            _saveButton(context, state),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PrimaryButton(
                label: state.readOnly ? 'Đã nộp bài' : 'Nộp bài',
                loading: state.submitting,
                onPressed:
                    canSubmit ? () => _confirmSubmit(context, state) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final ButtonStyle _compact = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    visualDensity: VisualDensity.compact,
  );

  Widget _exitButton(BuildContext context) {
    return OutlinedButton(
      style: _compact,
      onPressed: () => Navigator.of(context).maybePop(),
      child: const Text('Thoát'),
    );
  }

  Widget _saveButton(BuildContext context, ExamTakingState state) {
    final canSave = state.paper != null && !state.readOnly && !state.saving;
    return OutlinedButton(
      style: _compact,
      onPressed: canSave ? () => _save(context) : null,
      child: state.saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Lưu'),
    );
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<ExamTakingCubit>();
    await cubit.saveDraft();
    if (!context.mounted) return;
    if (cubit.state.error == null) {
      AppSnackBar.success(context, 'Đã lưu bài làm');
    }
  }

  Future<bool> _confirmExit(BuildContext context) {
    if (context.read<ExamTakingCubit>().state.readOnly) {
      return Future.value(true);
    }
    return AppDialogs.confirm(
      context,
      title: 'Thoát',
      message: 'Thoát khỏi bài làm? Hãy bấm "Lưu" trước nếu muốn giữ tiến độ.',
      confirmText: 'Thoát',
      cancelText: 'Ở lại',
      danger: true,
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.answered, required this.total});

  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : answered / total;
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đã trả lời $answered/$total câu',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius:
                const BorderRadius.all(Radius.circular(AppRadii.pill)),
            child: LinearProgressIndicator(value: ratio, minHeight: 6),
          ),
        ],
      ),
    );
  }
}

class _DonePill extends StatelessWidget {
  const _DonePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.16),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            'Đã nộp',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
