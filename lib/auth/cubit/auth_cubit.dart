import 'package:bloc/bloc.dart';
import 'package:deca_mobile/auth/data/auth_repository.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:equatable/equatable.dart';

/// Trang thai phien xac thuc.
///
/// `unknown` = dang kiem tra phien luc khoi dong (hien Splash).
enum AuthStatus { unknown, unauthenticated, loading, authenticated, failure }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  AuthState copyWith({AuthStatus? status, AuthUser? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}

/// Quan ly luong dang nhap / dang xuat / khoi phuc phien.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  /// Goi luc khoi dong. Giu `unknown` (Splash) cho den khi co ket qua.
  Future<void> restoreSession() async {
    final user = await _repository.tryGetMe();
    emit(
      user == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login(String username, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.login(
        username: username,
        password: password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on UnauthorizedException {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          error: 'Sai tài khoản hoặc mật khẩu',
        ),
      );
    } on ApiException catch (e) {
      emit(AuthState(status: AuthStatus.failure, error: e.message));
    } on Object catch (_) {
      emit(
        const AuthState(status: AuthStatus.failure, error: 'Đã có lỗi xảy ra'),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Hook 401 toan cuc — day ve Login khi token het han o bat ky man nao.
  void forceLogout() {
    if (state.status != AuthStatus.unauthenticated) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }
}
