import 'package:deca_mobile/core/network/api_client.dart';
import 'package:deca_mobile/core/network/api_exception.dart';
import 'package:deca_mobile/core/storage/token_storage.dart';

/// Thong tin nguoi dung — dung cho ca login va man Tai khoan.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    this.roles = const [],
    this.permissions = const [],
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] as num?)?.toInt() ?? 0,
        username: json['username'] as String,
        fullName: (json['fullName'] ?? json['username']) as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        roles: ((json['roles'] as List?) ?? const [])
            .map((e) => '$e')
            .toList(),
        permissions: ((json['permissions'] as List?) ?? const [])
            .map((e) => '$e')
            .toList(),
      );

  final int id;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final List<String> roles;
  final List<String> permissions;
}

/// Goi API xac thuc cua backend Spring Boot (Auth + RBAC) qua [ApiClient].
class AuthRepository {
  const AuthRepository({
    required ApiClient api,
    required TokenStorage tokenStorage,
  })  : _api = api,
        _tokens = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokens;

  /// Dang nhap, luu token khi thanh cong.
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/v1/auth/login',
      body: {'username': username, 'password': password},
    );
    final map = data! as Map<String, dynamic>;

    final access = map['accessToken'] as String?;
    if (access == null) {
      throw const ServerException('Phản hồi đăng nhập không hợp lệ');
    }
    await _tokens.save(access: access, refresh: map['refreshToken'] as String?);
    return AuthUser.fromJson(map['user']! as Map<String, dynamic>);
  }

  /// Khoi phuc phien: doc token -> GET /auth/me. Null neu khong co/het han.
  Future<AuthUser?> tryGetMe() async {
    final token = await _tokens.readAccess();
    if (token == null) return null;
    try {
      final data = await _api.get('/api/v1/auth/me');
      return AuthUser.fromJson(data! as Map<String, dynamic>);
    } on ApiException {
      await _tokens.clear();
      return null;
    }
  }

  /// Dang xuat: thu hoi refresh token o BE (bo qua loi mang) + xoa cuc bo.
  Future<void> logout() async {
    final refresh = await _tokens.readRefresh();
    if (refresh != null) {
      try {
        await _api.post('/api/v1/auth/logout', body: {'refreshToken': refresh});
      } on Object catch (_) {
        // bo qua loi mang khi dang xuat
      }
    }
    await _tokens.clear();
  }
}
