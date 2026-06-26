import 'package:deca_mobile/core/state/view_status.dart';
import 'package:equatable/equatable.dart';

/// State bat bien dung chung cho moi module tai du lieu.
///
/// `copyWith` giu nguyen ngu nghia cua AuthState: `data` giu lai (??),
/// `error` tu reset moi lan emit tru khi truyen vao.
class DataState<T> extends Equatable {
  const DataState({
    this.status = ViewStatus.initial,
    this.data,
    this.error,
  });

  final ViewStatus status;
  final T? data;
  final String? error;

  bool get isLoading => status == ViewStatus.loading;
  bool get isFailure => status == ViewStatus.failure;
  bool get hasData => data != null;

  DataState<T> copyWith({ViewStatus? status, T? data, String? error}) {
    return DataState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
