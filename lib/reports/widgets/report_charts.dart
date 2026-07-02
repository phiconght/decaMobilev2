import 'package:deca_mobile/reports/data/models/report_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Màu thống nhất — chủ đạo đỏ-trắng (Mobile_MauSac_DoTrang.md §4.6).
const _correct = Color(0xFF1E8E3E);
const _incorrect = Color(0xFF8C1D18);
const _ungraded = Color(0xFFD8CCCB);
const _coMat = Color(0xFF1E8E3E);
const _tre = Color(0xFFB26A00);
const _vang = Color(0xFF8C1D18);
const _coPhep = Color(0xFF3A5A80);
const _self = Color(0xFFBE2A3D); // mình = màu thương hiệu
const _classAvg = Color(0xFFB98A2C); // TB lớp = vàng đồng

const difficultyLabel = {'EASY': 'Dễ', 'MEDIUM': 'TB', 'HARD': 'Khó'};
const typeLabel = {
  'MULTIPLE_CHOICE': 'TN',
  'TRUE_FALSE': 'Đ/S',
  'ESSAY': 'Tự luận',
};

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('Chưa có dữ liệu')),
      );
}

/// Phổ điểm lớp (histogram): cột chứa HV màu xanh, còn lại xám; + percentile.
class ScoreDistributionChart extends StatelessWidget {
  const ScoreDistributionChart({required this.data, super.key});

  final ScoreDistribution? data;

  @override
  Widget build(BuildContext context) {
    final d = data;
    if (d == null || d.bands.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Chưa đủ dữ liệu phổ điểm')),
      );
    }
    final maxCount = d.bands.fold<int>(0, (m, b) => b.count > m ? b.count : m);
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < d.bands.length; i++) {
      final b = d.bands[i];
      groups.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: b.count.toDouble(),
            width: 16,
            color: b.containsStudent ? _self : const Color(0xFFBFBFBF),
            borderRadius: BorderRadius.zero,
          ),
        ]),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: (maxCount == 0 ? 1 : maxCount).toDouble() + 1,
              barGroups: groups,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (v, _) =>
                        Text('${v.toInt()}', style: const TextStyle(fontSize: 9)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= d.bands.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          d.bands[idx].toScore.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 8),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (d.studentScore != null)
          Text(
            'Con cao hơn ${d.percentile ?? 0}% các bạn'
            '${d.rank != null ? ' · hạng ${d.rank}/${d.submittedCount ?? '—'}' : ''}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          )
        else
          Text(
            'TB lớp ${d.classAverage ?? '—'} · trung vị ${d.median ?? '—'} · '
            '${d.submittedCount ?? 0} HV',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
      ],
    );
  }
}

/// Phổ điểm TỔNG của khóa — histogram NGANG (trục điểm 0–10 dọc, cột đâm ngang),
/// đường nét đứt "Điểm của bạn". Vẽ bằng CustomPaint (kiểu phổ điểm THPT).
class CourseScoreSpectrum extends StatelessWidget {
  const CourseScoreSpectrum({required this.data, this.height = 460, super.key});

  final ScoreDistribution? data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final d = data;
    if (d == null || d.bands.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Chưa đủ dữ liệu phổ điểm')),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _SpectrumPainter(d)),
        ),
        const SizedBox(height: 6),
        Text(
          d.studentScore != null
              ? 'Con cao hơn ${d.percentile ?? 0}% các bạn · TB khóa ${d.classAverage ?? '—'} · ${d.submittedCount ?? 0} HV'
              : 'TB khóa ${d.classAverage ?? '—'} · trung vị ${d.median ?? '—'} · ${d.submittedCount ?? 0} HV',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter(this.d);

  final ScoreDistribution d;
  static const _spectrum = Color(0xFFB45309);
  static const _mine = Color(0xFFC8102E);
  static const _axis = Color(0xFF8C8C8C);

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 30.0;
    const padR = 8.0;
    const padT = 10.0;
    const padB = 10.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;
    final maxScore = d.maxScore ?? 10;
    final maxCount = d.bands.fold<int>(1, (m, b) => b.count > m ? b.count : m);

    double yOf(double s) => padT + (1 - s / maxScore) * plotH;

    final grid = Paint()
      ..color = const Color(0xFFEFEFEF)
      ..strokeWidth = 1;
    for (var s = 0; s <= maxScore.round(); s++) {
      final y = yOf(s.toDouble());
      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y), grid);
      final tp = TextPainter(
        text: TextSpan(
            text: '$s', style: const TextStyle(color: _axis, fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padL - tp.width - 4, y - tp.height / 2));
    }
    canvas.drawLine(Offset(padL, padT), Offset(padL, size.height - padB),
        Paint()..color = _axis);

    for (final b in d.bands) {
      final top = yOf(b.toScore);
      final bottom = yOf(b.fromScore);
      final w = b.count == 0 ? 0.0 : (b.count / maxCount) * plotW;
      if (w <= 0) continue;
      final paint = Paint()
        ..color =
            (b.containsStudent ? _mine : _spectrum).withValues(alpha: 0.92);
      canvas.drawRect(
        Rect.fromLTWH(padL, top, w, (bottom - top - 1).clamp(1, plotH)),
        paint,
      );
    }

    final sv = d.studentScore;
    if (sv != null) {
      final y = yOf(sv);
      final dash = Paint()
        ..color = _axis
        ..strokeWidth = 1.5;
      var x = padL;
      while (x < size.width - padR) {
        canvas.drawLine(
            Offset(x, y),
            Offset((x + 6).clamp(0, size.width - padR), y),
            dash);
        x += 10;
      }
      final tp = TextPainter(
        text: TextSpan(
          text: 'Điểm của bạn: ${sv.toString().replaceAll('.', ',')}',
          style: const TextStyle(
              color: _axis, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - padR - tp.width, y - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter old) => old.d != d;
}

/// Đường xu hướng: điểm HV (%) vs TB lớp (%).
class ScoreTrendChart extends StatelessWidget {
  const ScoreTrendChart({required this.points, super.key});

  final List<ScoreTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _Empty();
    final self = <FlSpot>[];
    final avg = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      final s = points[i].selfPct;
      final a = points[i].avgPct;
      if (s != null) self.add(FlSpot(i.toDouble(), s));
      if (a != null) avg.add(FlSpot(i.toDouble(), a));
    }
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 25,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${idx + 1}',
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(horizontalInterval: 25),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: self,
                  color: _self,
                  barWidth: 2,
                  dotData: const FlDotData(),
                ),
                LineChartBarData(
                  spots: avg,
                  color: _classAvg,
                  barWidth: 2,
                  dashArray: [5, 4],
                  dotData: const FlDotData(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Legend(color: _self, label: 'Điểm của bạn'),
            SizedBox(width: 16),
            _Legend(color: _classAvg, label: 'TB lớp'),
          ],
        ),
      ],
    );
  }
}

/// Cột chồng Đúng/Sai/Chờ chấm theo nhóm (độ khó hoặc loại câu).
class BreakdownBarChart extends StatelessWidget {
  const BreakdownBarChart({
    required this.buckets,
    required this.labelMap,
    super.key,
  });

  final List<BucketStat> buckets;
  final Map<String, String> labelMap;

  @override
  Widget build(BuildContext context) {
    final total = buckets.fold<int>(
      0,
      (s, b) => s + b.correctCount + b.incorrectCount + b.ungradedCount,
    );
    if (total == 0) return const _Empty();

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < buckets.length; i++) {
      final b = buckets[i];
      final c = b.correctCount.toDouble();
      final w = b.incorrectCount.toDouble();
      final u = b.ungradedCount.toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: c + w + u,
              width: 22,
              borderRadius: BorderRadius.zero,
              rodStackItems: [
                BarChartRodStackItem(0, c, _correct),
                BarChartRodStackItem(c, c + w, _incorrect),
                BarChartRodStackItem(c + w, c + w + u, _ungraded),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: groups,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= buckets.length) {
                        return const SizedBox.shrink();
                      }
                      final k = buckets[idx].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(labelMap[k] ?? k,
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Legend(color: _correct, label: 'Đúng'),
            SizedBox(width: 12),
            _Legend(color: _incorrect, label: 'Sai'),
            SizedBox(width: 12),
            _Legend(color: _ungraded, label: 'Chờ chấm'),
          ],
        ),
      ],
    );
  }
}

/// Nắm chắc theo chương — radar (≤8 chương) hoặc bar ngang (>8).
class TopicMasteryChart extends StatelessWidget {
  const TopicMasteryChart({required this.items, super.key});

  final List<TopicMastery> items;

  @override
  Widget build(BuildContext context) {
    final data = items.where((t) => t.masteryPct != null).toList();
    if (data.length < 3) {
      // Radar cần ≥3 trục; ít hơn thì hiện dạng thanh.
      return _bars(data);
    }
    if (data.length > 8) return _bars(data);

    return SizedBox(
      height: 280,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
          radarBorderData: const BorderSide(color: Colors.grey, width: 0.5),
          gridBorderData: const BorderSide(color: Colors.grey, width: 0.3),
          tickBorderData: const BorderSide(color: Colors.grey, width: 0.3),
          getTitle: (index, angle) => RadarChartTitle(
            text: data[index].topicName.length > 10
                ? '${data[index].topicName.substring(0, 10)}…'
                : data[index].topicName,
          ),
          titleTextStyle: const TextStyle(fontSize: 9),
          dataSets: [
            RadarDataSet(
              fillColor: _self.withValues(alpha: 0.25),
              borderColor: _self,
              borderWidth: 2,
              entryRadius: 2,
              dataEntries: data
                  .map((t) => RadarEntry(value: (t.masteryPct ?? 0) * 100))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bars(List<TopicMastery> data) {
    if (data.isEmpty) return const _Empty();
    return Column(
      children: data.map((t) {
        final pct = ((t.masteryPct ?? 0) * 100).round();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(t.topicName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(width: 8),
              Text('$pct%', style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Donut phân bố chuyên cần + tỉ lệ đi đủ ở giữa.
class AttendanceDonut extends StatelessWidget {
  const AttendanceDonut({required this.summary, super.key});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];
    void add(String label, int value, Color color) {
      if (value <= 0) return;
      sections.add(
        PieChartSectionData(
          value: value.toDouble(),
          color: color,
          title: '$value',
          radius: 42,
          titleStyle: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    add('Có mặt', summary.coMat, _coMat);
    add('Trễ', summary.tre, _tre);
    add('Vắng', summary.vang + summary.chuaCheckin, _vang);
    add('Có phép', summary.coPhep, _coPhep);

    if (sections.isEmpty) return const _Empty();

    final rate = summary.attendanceRate;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                ),
              ),
              Text(
                rate != null ? '${(rate * 100).round()}%' : '—',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: const [
            _Legend(color: _coMat, label: 'Có mặt'),
            _Legend(color: _tre, label: 'Trễ'),
            _Legend(color: _vang, label: 'Vắng'),
            _Legend(color: _coPhep, label: 'Có phép'),
          ],
        ),
      ],
    );
  }
}

/// Đường TB lớp qua các đề (%).
class ClassAvgChart extends StatelessWidget {
  const ClassAvgChart({required this.items, super.key});

  final List<ClassExamAverage> items;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < items.length; i++) {
      final p = items[i].pct;
      if (p != null) spots.add(FlSpot(i.toDouble(), p));
    }
    if (spots.isEmpty) return const _Empty();
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (v, _) =>
                    Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${idx + 1}',
                        style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(horizontalInterval: 25),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: _self,
              barWidth: 2,
              dotData: const FlDotData(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
