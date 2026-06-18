import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/payment_result_entity.dart';
import '../../../domain/usecases/payment/payment_usecases.dart';

// Events
abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentTopupRequested extends PaymentEvent {
  final double amount;
  PaymentTopupRequested(this.amount);
  @override
  List<Object?> get props => [amount];
}

class PaymentTransferRequested extends PaymentEvent {
  final double amount;
  final String description;
  final String otpCode;
  final String otpType;
  PaymentTransferRequested({
    required this.amount,
    required this.description,
    required this.otpCode,
    required this.otpType,
  });
  @override
  List<Object?> get props => [amount, description, otpCode, otpType];
}

class PaymentReset extends PaymentEvent {}

// States
abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}

class PaymentTopupSuccess extends PaymentState {
  final double balance;
  final double amount;
  PaymentTopupSuccess({required this.balance, required this.amount});
  @override
  List<Object?> get props => [balance, amount];
}

class PaymentTransferSuccess extends PaymentState {
  final TransferResultEntity result;
  PaymentTransferSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class PaymentInvalidOtp extends PaymentState {
  final String message;
  PaymentInvalidOtp(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentInsufficientBalance extends PaymentState {
  final double balance;
  final double amount;
  PaymentInsufficientBalance({required this.balance, required this.amount});
  @override
  List<Object?> get props => [balance, amount];
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final TopupUsecase _topup;
  final TransferUsecase _transfer;

  PaymentBloc({required TopupUsecase topup, required TransferUsecase transfer})
      : _topup = topup,
        _transfer = transfer,
        super(PaymentInitial()) {
    on<PaymentTopupRequested>(_onTopup);
    on<PaymentTransferRequested>(_onTransfer);
    on<PaymentReset>((_, emit) => emit(PaymentInitial()));
  }

  Future<void> _onTopup(PaymentTopupRequested event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final result = await _topup(event.amount);
      emit(PaymentTopupSuccess(balance: result.balance, amount: result.amount));
    } on ServerFailure catch (e) {
      emit(PaymentError(e.message));
    } on NetworkFailure catch (e) {
      emit(PaymentError(e.message));
    }
  }

  Future<void> _onTransfer(PaymentTransferRequested event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final result = await _transfer(
        amount: event.amount,
        description: event.description,
        otpCode: event.otpCode,
        otpType: event.otpType,
      );
      emit(PaymentTransferSuccess(result));
    } on InvalidOtpFailure catch (e) {
      emit(PaymentInvalidOtp(e.message));
    } on InsufficientBalanceFailure catch (e) {
      emit(PaymentInsufficientBalance(balance: e.balance, amount: e.amount));
    } on ServerFailure catch (e) {
      emit(PaymentError(e.message));
    } on NetworkFailure catch (e) {
      emit(PaymentError(e.message));
    }
  }
}
