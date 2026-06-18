import '../../repositories/payment_repository.dart';
import '../../entities/payment_result_entity.dart';

class TopupUsecase {
  final PaymentRepository _repository;
  TopupUsecase(this._repository);
  Future<({double balance, double amount})> call(double amount) =>
      _repository.topup(amount);
}

class TransferUsecase {
  final PaymentRepository _repository;
  TransferUsecase(this._repository);
  Future<TransferResultEntity> call({
    required double amount,
    required String description,
    required String otpCode,
    required String otpType,
  }) =>
      _repository.transfer(
        amount: amount,
        description: description,
        otpCode: otpCode,
        otpType: otpType,
      );
}
