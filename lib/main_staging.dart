import 'package:deca_mobile/bootstrap.dart';
import 'package:deca_mobile/core/config/app_config.dart';

Future<void> main() async {
  await bootstrap(
    const AppConfig(baseUrl: 'http://localhost:9090', flavor: 'staging'),
  );
}
