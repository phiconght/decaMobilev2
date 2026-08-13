import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:deca_mobile/reports/widgets/score_color.dart';
import 'package:flutter/material.dart';

/// Danh sach chuong (cuon ngang), tap 1 the dan sang bao cao chuong —
/// mirror _RecentRow trong student_report_view.dart. Chi liet ke chuong
/// co topicId (bo "Chua phan chuong").
class ChapterCards extends StatelessWidget {
  const ChapterCards({required this.topics, required this.onTap, super.key});

  final List<TopicMastery> topics;
  final void Function(int topicId) onTap;

  @override
  Widget build(BuildContext context) {
    final items = topics.where((t) => t.topicId != null).toList();
    if (items.isEmpty) {
      return const Text('Chưa có chương nào.');
    }
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = items[i];
          final color = t.masteryPct != null
              ? scoreColor(t.masteryPct!)
              : Colors.grey;
          return SizedBox(
            width: 120,
            child: Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                onTap: () => onTap(t.topicId!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.masteryPct != null
                            ? '${(t.masteryPct! * 100).round()}%'
                            : '—',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(t.topicName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11)),
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
