import 'package:deca_mobile/core/network/api_client.dart';

/// Cau hinh dung chung toan he thong (hotline...) — GET /api/v1/app-settings,
/// cong khai, tai 1 lan luc mo app (xem AppSettingsCubit).
abstract class AppSettingsRepository {
  Future<String> fetchSupportHotline();
}

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  const AppSettingsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<String> fetchSupportHotline() async {
    final data = await _api.get('/api/v1/app-settings');
    final json = data! as Map<String, dynamic>;
    return json['supportHotline'] as String;
  }
}
