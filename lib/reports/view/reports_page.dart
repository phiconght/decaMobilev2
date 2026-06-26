import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:deca_mobile/reports/cubit/reports_cubit.dart';
import 'package:deca_mobile/reports/data/models/report.dart';
import 'package:deca_mobile/reports/view/report_detail_page.dart';
import 'package:deca_mobile/reports/widgets/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, DataState<List<Report>>>(
      builder: (context, state) {
        final items = state.data ?? const <Report>[];
        final refresh = context.read<ReportsCubit>().refresh;

        if (state.isLoading && items.isEmpty) {
          return const AppLoadingView();
        }
        if (state.isFailure && items.isEmpty) {
          return AppErrorView(
            message: state.error ?? 'Đã có lỗi xảy ra',
            onRetry: refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (items.isEmpty) ...[
                const SizedBox(height: 96),
                const AppEmptyView(message: 'Chưa có kết quả bài làm.'),
              ] else ...[
                _OverviewCard(items: items),
                const SizedBox(height: 16),
                Text(
                  'Kết quả gần đây',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final report in items) ...[
                  ReportCard(
                    report: report,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReportDetailPage(report: report),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.items});

  final List<Report> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg =
        items.map((e) => e.score).reduce((a, b) => a + b) / items.length;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Điểm trung bình',
                value: avg.toStringAsFixed(1),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.onPrimaryContainer
                  .withValues(alpha: 0.2),
            ),
            Expanded(
              child: _Metric(label: 'Bài đã làm', value: '${items.length}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
