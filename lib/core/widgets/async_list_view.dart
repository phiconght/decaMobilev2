import 'package:deca_mobile/core/state/data_state.dart';
import 'package:deca_mobile/core/widgets/app_empty_view.dart';
import 'package:deca_mobile/core/widgets/app_error_view.dart';
import 'package:deca_mobile/core/widgets/app_loading_view.dart';
import 'package:flutter/material.dart';

/// Bao 4 trang thai (loading/success/empty/error) + pull-to-refresh cho mot
/// danh sach dung tu [DataState].
class AsyncListView<T> extends StatelessWidget {
  const AsyncListView({
    required this.state,
    required this.itemBuilder,
    required this.onRefresh,
    this.emptyMessage = 'Chưa có dữ liệu',
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final DataState<List<T>> state;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;
  final String emptyMessage;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final items = state.data ?? const [];

    if (state.isLoading && items.isEmpty) {
      return const AppLoadingView();
    }
    if (state.isFailure && items.isEmpty) {
      return AppErrorView(
        message: state.error ?? 'Đã có lỗi xảy ra',
        onRetry: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 96),
                AppEmptyView(message: emptyMessage),
              ],
            )
          : ListView.separated(
              padding: padding,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => itemBuilder(context, items[i]),
            ),
    );
  }
}
