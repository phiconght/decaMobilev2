import 'package:deca_mobile/core/theme/app_colors.dart';
import 'package:deca_mobile/core/theme/app_spacing.dart';
import 'package:deca_mobile/exams/data/models/exam_paper.dart';
import 'package:deca_mobile/exams/data/models/exam_question.dart';
import 'package:deca_mobile/exams/widgets/exam_image.dart';
import 'package:flutter/material.dart';

/// The hien thi 1 cau hoi + vung tra loi theo dang; ho tro che do chi-xem
/// (readOnly) va hien ket qua cham (result) sau khi nop.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.index,
    required this.question,
    required this.readOnly,
    required this.selectedOptionId,
    required this.tfPicks,
    required this.essayText,
    required this.onSelectOption,
    required this.onSetTf,
    required this.onSetEssay,
    this.result,
    super.key,
  });

  final int index;
  final ExamQuestion question;
  final bool readOnly;
  final int? selectedOptionId;
  final Map<int, bool> tfPicks;
  final String essayText;
  final ValueChanged<int> onSelectOption;
  // bool Dung/Sai de positional cho closure goi gon (named gay loi suy luan).
  // ignore: avoid_positional_boolean_parameters
  final void Function(int itemId, bool value) onSetTf;
  final ValueChanged<String> onSetEssay;
  final QuestionResult? result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(theme),
            if (question.questionText != null &&
                question.questionText!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(question.questionText!, style: theme.textTheme.bodyLarge),
            ],
            if (question.questionImage != null) ...[
              const SizedBox(height: AppSpacing.md),
              ExamImage(url: question.questionImage!),
            ],
            const SizedBox(height: AppSpacing.md),
            _answerArea(theme),
          ],
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: scheme.primary,
          child: Text(
            '$index',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _TypeChip(type: question.type),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (result != null)
          _ResultChip(result: result!, type: question.type)
        else
          Text(
            _fmtPoints(question.points),
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _answerArea(ThemeData theme) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        if (question.options.isEmpty) return _emptyHint(theme);
        return Column(
          children: [
            for (var i = 0; i < question.options.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.sm),
                child: _OptionTile(
                  letter: String.fromCharCode(65 + i),
                  option: question.options[i],
                  selected: selectedOptionId == question.options[i].id,
                  readOnly: readOnly,
                  reveal: result != null,
                  onTap: () => onSelectOption(question.options[i].id),
                ),
              ),
          ],
        );
      case QuestionType.trueFalse:
        if (question.tfItems.isEmpty) return _emptyHint(theme);
        return Column(
          children: [
            for (var i = 0; i < question.tfItems.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.md),
                child: _TfRow(
                  item: question.tfItems[i],
                  picked: tfPicks[question.tfItems[i].id],
                  readOnly: readOnly,
                  reveal: result != null,
                  onSet: (value) => onSetTf(question.tfItems[i].id, value),
                ),
              ),
          ],
        );
      case QuestionType.essay:
        return _EssayAnswer(
          question: question,
          text: essayText,
          readOnly: readOnly,
          reveal: result != null,
          onChanged: onSetEssay,
        );
    }
  }

  Widget _emptyHint(ThemeData theme) => Text(
        'Câu hỏi chưa có phương án.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
}

// ---------------------------------------------------------------------------

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final QuestionType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      QuestionType.multipleChoice => ('Trắc nghiệm', AppColors.info),
      QuestionType.essay => ('Tự luận', const Color(0xFF7C3AED)),
      QuestionType.trueFalse => ('Đúng – Sai', const Color(0xFF0891B2)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.result, required this.type});

  final QuestionResult result;
  final QuestionType type;

  @override
  Widget build(BuildContext context) {
    if (type == QuestionType.essay) {
      return const _Pill(
        label: 'Chấm tay',
        color: AppColors.neutral,
        icon: Icons.edit_note,
      );
    }
    final correct = result.correct ?? false;
    final partial = !correct && result.earned > 0;
    final label = correct
        ? 'Đúng · ${_fmtPoints(result.earned)}'
        : partial
            ? 'Đúng một phần · ${_fmtPoints(result.earned)}'
            : 'Sai';
    final color = correct
        ? AppColors.success
        : partial
            ? AppColors.warning
            : AppColors.danger;
    final icon = correct
        ? Icons.check_circle
        : partial
            ? Icons.adjust
            : Icons.cancel;
    return _Pill(label: label, color: color, icon: icon);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.option,
    required this.selected,
    required this.readOnly,
    required this.reveal,
    required this.onTap,
  });

  final String letter;
  final QuestionOption option;
  final bool selected;
  final bool readOnly;
  final bool reveal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Mau vien/nen theo trang thai: review (dung/sai) > dang chon > mac dinh.
    var borderColor = scheme.outlineVariant;
    var bgColor = scheme.surface;
    Widget? mark;
    if (reveal && option.isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.08);
      mark = const Icon(Icons.check_circle, color: AppColors.success, size: 20);
    } else if (reveal && selected) {
      borderColor = AppColors.danger;
      bgColor = AppColors.danger.withValues(alpha: 0.08);
      mark = const Icon(Icons.cancel, color: AppColors.danger, size: 20);
    } else if (selected) {
      borderColor = scheme.primary;
      bgColor = scheme.primary.withValues(alpha: 0.08);
    }

    final leading = CircleAvatar(
      radius: 14,
      backgroundColor:
          selected && !reveal ? scheme.primary : scheme.surfaceContainerHighest,
      child: Text(
        letter,
        style: theme.textTheme.labelMedium?.copyWith(
          color: selected && !reveal
              ? scheme.onPrimary
              : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return InkWell(
      borderRadius: AppRadii.rmd,
      onTap: readOnly ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.rmd,
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (option.text != null && option.text!.isNotEmpty)
                    Text(option.text!, style: theme.textTheme.bodyMedium),
                  if (option.image != null) ...[
                    if (option.text != null && option.text!.isNotEmpty)
                      const SizedBox(height: AppSpacing.sm),
                    ExamImage(url: option.image!, height: 140),
                  ],
                ],
              ),
            ),
            if (mark != null) ...[
              const SizedBox(width: AppSpacing.sm),
              mark,
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TfRow extends StatelessWidget {
  const _TfRow({
    required this.item,
    required this.picked,
    required this.readOnly,
    required this.reveal,
    required this.onSet,
  });

  final TfItem item;
  final bool? picked;
  final bool readOnly;
  final bool reveal;
  final ValueChanged<bool> onSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wrong = reveal && picked != null && picked != item.answer;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadii.rmd,
        border: Border.all(
          color: wrong ? AppColors.danger : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.text != null && item.text!.isNotEmpty)
            Text(item.text!, style: theme.textTheme.bodyMedium),
          if (item.image != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ExamImage(url: item.image!, height: 140),
          ],
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Đúng'),
                icon: Icon(Icons.check),
              ),
              ButtonSegment(
                value: false,
                label: Text('Sai'),
                icon: Icon(Icons.close),
              ),
            ],
            selected: picked == null ? <bool>{} : {picked!},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged:
                readOnly ? null : (set) => onSet(set.first),
          ),
          if (reveal) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Đáp án đúng: ${item.answer ? 'Đúng' : 'Sai'}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: wrong ? AppColors.danger : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EssayAnswer extends StatelessWidget {
  const _EssayAnswer({
    required this.question,
    required this.text,
    required this.readOnly,
    required this.reveal,
    required this.onChanged,
  });

  final ExamQuestion question;
  final String text;
  final bool readOnly;
  final bool reveal;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (readOnly)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: AppRadii.rmd,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              text.trim().isEmpty ? 'Chưa trả lời' : text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: text.trim().isEmpty ? scheme.onSurfaceVariant : null,
                fontStyle: text.trim().isEmpty ? FontStyle.italic : null,
              ),
            ),
          )
        else
          _EssayField(initialText: text, onChanged: onChanged),
        if (reveal &&
            question.essayAnswer != null &&
            question.essayAnswer!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: AppRadii.rmd,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đáp án gợi ý',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(question.essayAnswer!, style: theme.textTheme.bodyMedium),
                if (question.essayAnswerImage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ExamImage(url: question.essayAnswerImage!, height: 160),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _EssayField extends StatefulWidget {
  const _EssayField({required this.initialText, required this.onChanged});

  final String initialText;
  final ValueChanged<String> onChanged;

  @override
  State<_EssayField> createState() => _EssayFieldState();
}

class _EssayFieldState extends State<_EssayField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      minLines: 4,
      maxLines: 8,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        hintText: 'Nhập câu trả lời của bạn...',
        border: OutlineInputBorder(),
      ),
    );
  }
}

String _fmtPoints(double p) => '${formatPoints(p)} điểm';
