import 'package:deca_mobile/app/app.dart';
import 'package:deca_mobile/auth/view/login_page.dart';
import 'package:deca_mobile/core/config/app_config.dart';
import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('App', () {
    testWidgets('renders LoginPage when unauthenticated', (tester) async {
      const tokenStorage = TokenStorage(FlutterSecureStorage());
      final apiClient = ApiClient(
        config: const AppConfig(baseUrl: 'http://localhost', flavor: 'test'),
        tokenStorage: tokenStorage,
      );

      await tester.pumpWidget(
        App(apiClient: apiClient, tokenStorage: tokenStorage),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
