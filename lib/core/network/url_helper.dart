import 'package:deca_mobile/core/config/app_config.dart';

/// Extension: tao URL tuyet doi tu URL tuong doi (neu can).
///
/// BE tra ve URL anh dang tuong doi (vd `/api/v1/files/123/content`) vi
/// khong biet truoc client goi tu dau (localhost / 10.0.2.2 / IP thiet bi
/// that). Client tu ghep `baseUrl` cua chinh no la dung cho moi truong hop.
extension AbsoluteUrlExt on AppConfig {
  /// Tra ve chuoi rong neu [url] null/rong. Giu nguyen neu da la URL tuyet
  /// doi (http/https). Nguoc lai ghep [baseUrl] vao truoc.
  String toAbsoluteUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }
}
