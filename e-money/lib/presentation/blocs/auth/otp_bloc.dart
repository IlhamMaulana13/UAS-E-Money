import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/otp_entity.dart';
import '../../../domain/usecases/auth/send_otp_usecase.dart';

// Events
abstract class OtpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtpSendFirebase extends OtpEvent {}
class OtpSendEmail extends OtpEvent {}
class OtpConfirm extends OtpEvent {
  final String code;
  final String otpType;
  OtpConfirm({required this.code, required this.otpType});
  @override
  List<Object?> get props => [code, otpType];
}
class OtpRegisterTotp extends OtpEvent {}
class OtpVerifyTotp extends OtpEvent {
  final String code;
  OtpVerifyTotp(this.code);
  @override
  List<Object?> get props => [code];
}
class OtpReset extends OtpEvent {}

// States
abstract class OtpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}
class OtpLoading extends OtpState {}
class OtpSent extends OtpState {
  final OtpSentEntity entity;
  OtpSent(this.entity);
  @override
  List<Object?> get props => [entity];
}
class OtpVerified extends OtpState {}
class OtpTotpSetup extends OtpState {
  final TotpSetupEntity entity;
  OtpTotpSetup(this.entity);
  @override
  List<Object?> get props => [entity];
}
class OtpTotpEnabled extends OtpState {}
class OtpInvalid extends OtpState {
  final String message;
  OtpInvalid(this.message);
  @override
  List<Object?> get props => [message];
}
class OtpError extends OtpState {
  final String message;
  OtpError(this.message);
  @override
  List<Object?> get props => [message];
}

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final SendOtpFirebaseUsecase _sendFirebase;
  final SendOtpEmailUsecase _sendEmail;
  final ConfirmOtpUsecase _confirm;
  final RegisterTotpUsecase _registerTotp;
  final VerifyTotpUsecase _verifyTotp;

  OtpBloc({
    required SendOtpFirebaseUsecase sendFirebase,
    required SendOtpEmailUsecase sendEmail,
    required ConfirmOtpUsecase confirm,
    required RegisterTotpUsecase registerTotp,
    required VerifyTotpUsecase verifyTotp,
  })  : _sendFirebase = sendFirebase,
        _sendEmail = sendEmail,
        _confirm = confirm,
        _registerTotp = registerTotp,
        _verifyTotp = verifyTotp,
        super(OtpInitial()) {
    on<OtpSendFirebase>(_onSendFirebase);
    on<OtpSendEmail>(_onSendEmail);
    on<OtpConfirm>(_onConfirm);
    on<OtpRegisterTotp>(_onRegisterTotp);
    on<OtpVerifyTotp>(_onVerifyTotp);
    on<OtpReset>((_, emit) => emit(OtpInitial()));
  }

  Future<void> _onSendFirebase(OtpSendFirebase _, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      final entity = await _sendFirebase();
      emit(OtpSent(entity));
    } on ServerFailure catch (e) {
      emit(OtpError(e.message));
    } on NetworkFailure catch (e) {
      emit(OtpError(e.message));
    }
  }

  Future<void> _onSendEmail(OtpSendEmail _, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      final entity = await _sendEmail();
      emit(OtpSent(entity));
    } on ServerFailure catch (e) {
      emit(OtpError(e.message));
    } on NetworkFailure catch (e) {
      emit(OtpError(e.message));
    }
  }

  Future<void> _onConfirm(OtpConfirm event, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      await _confirm(code: event.code, otpType: event.otpType);
      emit(OtpVerified());
    } on InvalidOtpFailure catch (e) {
      emit(OtpInvalid(e.message));
    } on ServerFailure catch (e) {
      emit(OtpError(e.message));
    } on NetworkFailure catch (e) {
      emit(OtpError(e.message));
    }
  }

  Future<void> _onRegisterTotp(OtpRegisterTotp _, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      final entity = await _registerTotp();
      emit(OtpTotpSetup(entity));
    } on ServerFailure catch (e) {
      emit(OtpError(e.message));
    } on NetworkFailure catch (e) {
      emit(OtpError(e.message));
    }
  }

  Future<void> _onVerifyTotp(OtpVerifyTotp event, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      await _verifyTotp(event.code);
      emit(OtpTotpEnabled());
    } on InvalidOtpFailure catch (e) {
      emit(OtpInvalid(e.message));
    } on ServerFailure catch (e) {
      emit(OtpError(e.message));
    } on NetworkFailure catch (e) {
      emit(OtpError(e.message));
    }
  }
}
