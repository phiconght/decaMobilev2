import 'package:deca_mobile/bootstrap.dart';
import 'package:deca_mobile/core/config/app_config.dart';

Future<void> main() async {
  await bootstrap(
    // localhost:9090 khong bao gio dung tren dien thoai nguoi dung that —
    // day la endpoint API production that (DuckDNS, TLS qua Nginx tren VPS).
    // Sua 13/09/2026: file nay truoc do van tro localhost, nghia la ban
    // build production/Play Store se khong bao gio ket noi duoc.
    const AppConfig(
      baseUrl: 'https://decamath-api.duckdns.org',
      flavor: 'production',
    ),
  );
}
