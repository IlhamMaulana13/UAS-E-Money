import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/verify_firebase_token_usecase.dart';
import '../../../domain/usecases/auth/get_me_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/send_otp_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/error/failures.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}
class AuthLoginWithFirebase extends AuthEvent {
  final String firebaseToken;
  AuthLoginWithFirebase(this.firebaseToken);
  @override
  List<Object?> get props => [firebaseToken];
}
class AuthLogoutRequested extends AuthEvent {}
class AuthUpdateFcmToken extends AuthEvent {
  final String fcmToken;
  AuthUpdateFcmToken(this.fcmToken);
  @override
  List<Object?> get props => [fcmToken];
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthNeedsVerification extends AuthState {
  final UserEntity user;
  final String token;
  AuthNeedsVerification(this.user, this.token);
  @override
  List<Object?> get props => [user, token];
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final VerifyFirebaseTokenUsecase _verifyToken;
  final GetMeUsecase _getMe;
  final LogoutUsecase _logout;
  final AuthRepository _authRepo;

  AuthBloc({
    required VerifyFirebaseTokenUsecase verifyToken,
    required GetMeUsecase getMe,
    required LogoutUsecase logout,
    required AuthRepository authRepo,
  })  : _verifyToken = verifyToken,
        _getMe = getMe,
        _logout = logout,
        _authRepo = authRepo,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginWithFirebase>(_onLoginWithFirebase);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthUpdateFcmToken>(_onUpdateFcm);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final token = await _authRepo.getSavedToken();
    if (token == null) {
      emit(AuthUnauthenticated());
      return;
    }
    final user = await _authRepo.getSavedUser();
    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }
    final verified = await _authRepo.isAuthVerified();
    if (!verified) {
      // Login berhasil tapi 2FA belum dikonfirmasi sebelum app ditutup →
      // anggap sesi tidak valid, mulai ulang dari awal (login/Google chooser).
      await _authRepo.logout();
      emit(AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(user));
  }

  Future<void> _onLoginWithFirebase(AuthLoginWithFirebase event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _verifyToken(event.firebaseToken);
      emit(AuthNeedsVerification(result.user, result.token));
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } on NetworkFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateFcm(AuthUpdateFcmToken event, Emitter<AuthState> emit) async {
    await _authRepo.updateFcmToken(event.fcmToken);
  }
}
