import '../entities/account_entity.dart';
import '../entities/transaction_entity.dart';

abstract class AccountRepository {
  Future<AccountEntity> getAccount();
  Future<List<TransactionEntity>> getTransactions();
}
