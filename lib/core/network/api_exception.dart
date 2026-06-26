/// Cay ngoai le chuan hoa cho moi loi goi API.
///
/// Moi loi xuong tang Repository/Cubit deu la [ApiException] voi [message]
/// da Viet hoa, hien thi truc tiep cho nguoi dung.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Khong ket noi duoc may chu (loi mang / timeout).
class NetworkException extends ApiException {
  const NetworkException() : super('Không kết nối được máy chủ');
}

/// HTTP 401 — token thieu/het han. Keo theo dang xuat toan cuc.
class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Phiên đăng nhập đã hết hạn');
}

/// HTTP 5xx — loi phia may chu.
class ServerException extends ApiException {
  const ServerException([super.message = 'Máy chủ gặp sự cố']);
}

/// HTTP 4xx co nghiep vu — kem [code] = ApiError.code cua BE.
class BusinessException extends ApiException {
  const BusinessException(super.message, {this.code});

  final String? code;
}
