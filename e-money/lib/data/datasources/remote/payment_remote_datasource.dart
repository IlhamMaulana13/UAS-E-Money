import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/payment_result_entity.dart';

abstract class PaymentRemoteDatasource {
  Future<({double balance, double amount})> topup(double amount);
  Future<TransferResultEntity> transfer({
    required double amount,
    required String description,
    required String otpCode,
    required String otpType,
  });
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final ApiClient _client;
  PaymentRemoteDatasourceImpl(this._client);

  @override
  Future<({double balance, double amount})> topup(double amount) async {
    final response = await _client.post(ApiEndpoints.topup, data: {'amount': amount});
    final data = response['data'] as Map<String, dynamic>;
    return (
      balance: (data['balance'] as num).toDouble(),
      amount: (data['amount'] as num).toDouble(),
    );
  }

  @override
  Future<TransferResultEntity> transfer({
    required double amount,
    required String description,
    required String otpCode,
    required String otpType,
  }) async {
    final response = await _client.post(ApiEndpoints.transfer, data: {
      'amount': amount,
      'description': description,
      'otp_code': otpCode,
      'otp_type': otpType,
    });
    final data = response['data'] as Map<String, dynamic>;
    return TransferResultEntity(
      transactionId: (data['transaction_id'] as num).toInt(),
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] as String? ?? '',
      balanceBefore: (data['balance_before'] as num).toDouble(),
      balanceAfter: (data['balance_after'] as num).toDouble(),
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
