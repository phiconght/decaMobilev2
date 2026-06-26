import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:deca_mobile/app/view/app.dart';
import 'package:deca_mobile/core/config/app_config.dart';
import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/storage/token_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// Dung ha tang dung chung (ApiClient, TokenStorage) roi chay App.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  const tokenStorage = TokenStorage(FlutterSecureStorage());
  final apiClient = ApiClient(config: config, tokenStorage: tokenStorage);

  runApp(App(apiClient: apiClient, tokenStorage: tokenStorage));
}
