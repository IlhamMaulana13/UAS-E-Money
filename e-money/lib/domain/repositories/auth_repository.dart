import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<({UserEntity user, String token})> verifyFirebaseToken(String firebaseToken);
  Future<({UserEntity user, String token})> registerWithOtp(String firebaseToken);
  Future<void> verifyEmailOtp(String code);
  Future<UserEntity> getMe();
  Future<void> updateFcmToken(String fcmToken);
  Future<void> logout();
  Future<String?> getSavedToken();
  Future<UserEntity?> getSavedUser();
  Future<void> setAuthVerified(bool verified);
  Future<bool> isAuthVerified();
}
