import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/account_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/account/get_account_usecase.dart';

// Events
abstract class AccountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class AccountLoadRequested extends AccountEvent {}
class AccountRefreshRequested extends AccountEvent {}

// States
abstract class AccountState extends Equatable {
  @override
  List<Object?> get props => [];
}
class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}
class AccountLoaded extends AccountState {
  final AccountEntity account;
  final List<TransactionEntity> transactions;
  AccountLoaded({required this.account, required this.transactions});
  @override
  List<Object?> get props => [account, transactions];
}
class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
  @override
  List<Object?> get props => [message];
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountUsecase _getAccount;
  final GetTransactionsUsecase _getTransactions;

  AccountBloc({
    required GetAccountUsecase getAccount,
    required GetTransactionsUsecase getTransactions,
  })  : _getAccount = getAccount,
        _getTransactions = getTransactions,
        super(AccountInitial()) {
    on<AccountLoadRequested>(_onLoad);
    on<AccountRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(AccountEvent event, Emitter<AccountState> emit) async {
    if (state is! AccountLoaded) emit(AccountLoading());
    try {
      final account = await _getAccount();
      final transactions = await _getTransactions();
      emit(AccountLoaded(account: account, transactions: transactions));
    } on ServerFailure catch (e) {
      emit(AccountError(e.message));
    } on NetworkFailure catch (e) {
      emit(AccountError(e.message));
    } catch (e) {
      emit(AccountError('Gagal memuat data akun.'));
    }
  }
}
