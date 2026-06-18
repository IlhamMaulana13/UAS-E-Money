import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/transaction_entity.dart';
import 'feature_icon.dart';

class TransactionRow extends StatelessWidget {
  final TransactionEntity txn;
  final bool divider;

  const TransactionRow({super.key, required this.txn, this.divider = false});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final (icon, tone) = _resolveIcon(txn.description);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (divider)
          const Divider(height: 1, thickness: 1, color: AppColors.line2, indent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              FeatureIcon(icon: icon, tone: tone, size: 44, iconSize: 21),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(txn.createdAt),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isCredit ? '+' : '-'}${CurrencyFormatter.format(txn.amount)}',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isCredit ? AppColors.green : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (IconData, String) _resolveIcon(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('top up') || d.contains('topup')) return (DkgIcons.topup, 'blue');
    if (d.contains('transfer')) return (DkgIcons.send, 'green');
    if (d.contains('qris') || d.contains('bayar')) return (DkgIcons.qris, 'violet');
    if (d.contains('pulsa')) return (DkgIcons.pulsa, 'blue');
    if (d.contains('tokobel') || d.contains('toko')) return (DkgIcons.store, 'amber');
    return (DkgIcons.wallet, 'slate');
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);
    final time = '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
    if (date == today) return 'Hari ini, $time';
    if (date == yesterday) return 'Kemarin, $time';
    return '${dt.day} ${_month(dt.month)}, $time';
  }

  String _month(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m - 1];
  }
}
