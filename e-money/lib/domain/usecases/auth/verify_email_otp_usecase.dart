import '../../repositories/auth_repository.dart';

class VerifyEmailOtpUsecase {
  final AuthRepository _repository;
  VerifyEmailOtpUsecase(this._repository);

  Future<void> call(String code) => _repository.verifyEmailOtp(code);
}
