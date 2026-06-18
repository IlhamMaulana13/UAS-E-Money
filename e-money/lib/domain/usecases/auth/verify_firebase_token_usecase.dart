import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class VerifyFirebaseTokenUsecase {
  final AuthRepository _repository;
  VerifyFirebaseTokenUsecase(this._repository);

  Future<({UserEntity user, String token})> call(String firebaseToken) {
    return _repository.verifyFirebaseToken(firebaseToken);
  }
}
