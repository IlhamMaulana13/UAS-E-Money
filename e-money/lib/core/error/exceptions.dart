class ServerException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;
  const ServerException(this.message, {this.errorCode, this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Tidak ada koneksi internet.']);
}

class UnauthorizedException implements Exception {
  final String message;
  final String? errorCode;
  const UnauthorizedException(this.message, {this.errorCode});
}

class InvalidOtpException implements Exception {
  final String message;
  const InvalidOtpException([this.message = 'Kode OTP tidak valid.']);
}

class InsufficientBalanceException implements Exception {
  final String message;
  final double? balance;
  final double? amount;
  const InsufficientBalanceException(this.message, {this.balance, this.amount});
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Gagal mengakses storage.']);
}
