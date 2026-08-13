import 'package:deca_mobile/courses/data/models/class_outline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Danh sach buoi hoc (cuon ngang), tap 1 the dan sang bao cao buoi —
/// mirror ChapterCards / _RecentRow.
class SessionCards extends StatelessWidget {
  const SessionCards({required this.sessions, required this.onTap, super.key});

  final List<OutlineSession> sessions;
  final void Function(int sessionId) onTap;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Text('Chưa có buổi học nào.');
    }
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final s = sessions[i];
          return SizedBox(
            width: 120,
            child: Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                onTap: () => onTap(s.sessionId),
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
                        'Buổi ${s.ordinal ?? '—'}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(s.title ?? 'Chưa đặt tên',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11)),
                      Text(
                        DateFormat('dd/MM').format(s.date),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
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
