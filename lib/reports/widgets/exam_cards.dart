import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:deca_mobile/reports/widgets/score_color.dart';
import 'package:flutter/material.dart';

/// Danh sach bai thi (cuon ngang), to mau theo ti le diem/maxScore — mirror
/// _RecentRow/RecentExamCards. Khong to mau ro rang thi nguoi dung khong
/// biet the nao la co the bam vao (dong gray giong nhau het).
class ExamCards extends StatelessWidget {
  const ExamCards({required this.exams, required this.onTap, super.key});

  final List<OutlineExam> exams;
  final void Function(OutlineExam) onTap;

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return const Text('Chưa có đề thi.');
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: exams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final e = exams[i];
          final ratio = e.score != null && e.maxScore != null && e.maxScore! > 0
              ? e.score! / e.maxScore!
              : null;
          final color = ratio != null ? scoreColor(ratio) : Colors.grey;
          return SizedBox(
            width: 160,
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: color, width: 3),
              ),
              child: InkWell(
                onTap: () => onTap(e),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.score?.toStringAsFixed(1) ?? '—',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(e.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
