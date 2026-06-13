import 'package:deca_mobile/app/app.dart';
import 'package:deca_mobile/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
