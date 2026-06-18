import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final String? errorCode;
  const ServerFailure(super.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet.']);
}

class AuthFailure extends Failure {
  final String? errorCode;
  const AuthFailure(super.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure([super.message = 'Kode OTP tidak valid atau sudah kadaluarsa.']);
}

class InsufficientBalanceFailure extends Failure {
  final double balance;
  final double amount;
  const InsufficientBalanceFailure({
    required this.balance,
    required this.amount,
    String message = 'Saldo tidak cukup.',
  }) : super(message);

  @override
  List<Object?> get props => [message, balance, amount];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal mengakses penyimpanan lokal.']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Terjadi kesalahan. Silakan coba lagi.']);
}
