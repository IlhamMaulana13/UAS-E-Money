import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/otp_entity.dart';

abstract class OtpRemoteDatasource {
  Future<OtpSentEntity> sendOtpFirebase();
  Future<OtpSentEntity> sendOtpEmail();
  Future<void> confirmOtp({required String code, required String otpType});
  Future<TotpSetupEntity> registerTotp();
  Future<bool> verifyTotp(String code);
}

class OtpRemoteDatasourceImpl implements OtpRemoteDatasource {
  final ApiClient _client;
  OtpRemoteDatasourceImpl(this._client);

  @override
  Future<OtpSentEntity> sendOtpFirebase() async {
    final response = await _client.post(ApiEndpoints.sendOtpFirebase);
    final data = response['data'] as Map<String, dynamic>;
    return OtpSentEntity(
      otpType: data['otp_type'] as String,
      expiresIn: (data['expires_in'] as num).toInt(),
    );
  }

  @override
  Future<OtpSentEntity> sendOtpEmail() async {
    final response = await _client.post(ApiEndpoints.sendOtpEmail);
    final data = response['data'] as Map<String, dynamic>;
    return OtpSentEntity(
      otpType: data['otp_type'] as String,
      expiresIn: (data['expires_in'] as num).toInt(),
    );
  }

  @override
  Future<void> confirmOtp({required String code, required String otpType}) async {
    await _client.post(ApiEndpoints.confirmOtp, data: {
      'code': code,
      'otp_type': otpType,
    });
  }

  @override
  Future<TotpSetupEntity> registerTotp() async {
    final response = await _client.post(ApiEndpoints.totpRegister);
    final data = response['data'] as Map<String, dynamic>;
    return TotpSetupEntity(
      secret: data['secret'] as String,
      qrCode: data['qr_code'] as String,
      issuer: data['issuer'] as String? ?? 'DKG',
      account: data['account'] as String? ?? '',
    );
  }

  @override
  Future<bool> verifyTotp(String code) async {
    final response = await _client.post(ApiEndpoints.totpVerify, data: {'code': code});
    final data = response['data'] as Map<String, dynamic>;
    return data['totp_enabled'] as bool? ?? false;
  }
}
