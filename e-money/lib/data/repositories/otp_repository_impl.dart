import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/otp_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/otp_repository.dart';
import '../datasources/remote/otp_remote_datasource.dart';

class OtpRepositoryImpl implements OtpRepository {
  final OtpRemoteDatasource _remote;
  final AuthRepository _authRepo;
  OtpRepositoryImpl(this._remote, this._authRepo);

  @override
  Future<OtpSentEntity> sendOtpFirebase() async {
    try {
      return await _remote.sendOtpFirebase();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<OtpSentEntity> sendOtpEmail() async {
    try {
      return await _remote.sendOtpEmail();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<void> confirmOtp({required String code, required String otpType}) async {
    try {
      await _remote.confirmOtp(code: code, otpType: otpType);
      await _authRepo.setAuthVerified(true);
    } on InvalidOtpException catch (e) {
      throw InvalidOtpFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<TotpSetupEntity> registerTotp() async {
    try {
      return await _remote.registerTotp();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<bool> verifyTotp(String code) async {
    try {
      final enabled = await _remote.verifyTotp(code);
      if (enabled) {
        await _authRepo.setAuthVerified(true);
      }
      return enabled;
    } on InvalidOtpException catch (e) {
      throw InvalidOtpFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }
}
