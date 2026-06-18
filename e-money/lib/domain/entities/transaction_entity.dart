import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

class TransactionEntity extends Equatable {
  final int id;
  final int accountId;
  final double amount;
  final TransactionType type;
  final String description;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.description,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });

  bool get isCredit => type == TransactionType.credit;
  double get signedAmount => isCredit ? amount : -amount;

  @override
  List<Object?> get props => [id, accountId, amount, type, description, createdAt];
}
