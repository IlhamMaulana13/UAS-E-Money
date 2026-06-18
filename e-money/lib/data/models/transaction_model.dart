import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.accountId,
    required super.amount,
    required super.type,
    required super.description,
    required super.balanceBefore,
    required super.balanceAfter,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'debit';
    return TransactionModel(
      id: (json['ID'] ?? json['id'] as num? ?? 0).toInt(),
      accountId: (json['account_id'] as num? ?? 0).toInt(),
      amount: (json['amount'] as num? ?? 0).toDouble(),
      type: typeStr == 'credit' ? TransactionType.credit : TransactionType.debit,
      description: json['description'] as String? ?? '',
      balanceBefore: (json['balance_before'] as num? ?? 0).toDouble(),
      balanceAfter: (json['balance_after'] as num? ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
