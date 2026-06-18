import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class GetMeUsecase {
  final AuthRepository _repository;
  GetMeUsecase(this._repository);

  Future<UserEntity> call() => _repository.getMe();
}
