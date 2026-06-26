/// Cau hinh chay theo flavor (dev/staging/prod).
///
/// `baseUrl` doi theo nen tang chay app:
/// - Web (Chrome) / desktop: http://localhost:9090
/// - Android emulator: http://10.0.2.2:9090
/// - Thiet bi that: `http://[IP-may-chay-BE]:9090`
class AppConfig {
  const AppConfig({required this.baseUrl, required this.flavor});

  final String baseUrl;
  final String flavor;
}
