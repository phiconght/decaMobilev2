import 'package:deca_mobile/settings/data/app_settings_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({this.supportHotline});

  final String? supportHotline;

  @override
  List<Object?> get props => [supportHotline];
}

/// Cau hinh dung chung — tai 1 lan luc mo app (giong InboxBadgeCubit: phu
/// tro, loi khi tai thi bo qua thay vi lam sap man hinh).
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._repository) : super(const AppSettingsState());

  final AppSettingsRepository _repository;

  Future<void> load() async {
    try {
      final hotline = await _repository.fetchSupportHotline();
      emit(AppSettingsState(supportHotline: hotline));
    } on Object catch (_) {
      // Bo qua: hotline khong bat buoc, noi hien no tu an neu thieu.
    }
  }
}
