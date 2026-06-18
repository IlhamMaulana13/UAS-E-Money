import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final DateTime createdAt;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, balance, createdAt];
}
