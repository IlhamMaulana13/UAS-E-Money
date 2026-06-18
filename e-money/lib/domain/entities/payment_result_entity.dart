import 'package:equatable/equatable.dart';

class PaymentResultEntity extends Equatable {
  final String title;
  final String subtitle;
  final double amount;
  final List<List<String>> lines;
  final String kind;

  const PaymentResultEntity({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.lines,
    required this.kind,
  });

  @override
  List<Object?> get props => [title, subtitle, amount, lines, kind];
}

class TransferResultEntity extends Equatable {
  final int transactionId;
  final double amount;
  final String description;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime createdAt;

  const TransferResultEntity({
    required this.transactionId,
    required this.amount,
    required this.description,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [transactionId, amount, description, balanceBefore, balanceAfter];
}
