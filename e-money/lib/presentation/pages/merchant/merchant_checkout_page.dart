import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';

const _orange = Color(0xFFFF6A2B);

class MerchantCheckoutPage extends StatelessWidget {
  const MerchantCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'Kemeja Flanel Oversize', 'qty': 1, 'price': 159000.0},
      {'name': 'Tumbler Stainless 750ml', 'qty': 2, 'price': 45000.0},
    ];
    const ship = 12000.0;
    final subtotal = items.fold(0.0, (s, i) => s + (i['price'] as double) * (i['qty'] as int));
    final total = subtotal + ship;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // TokoBelanja header (different brand!)
          Container(
            color: _orange,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 6, 16, 14),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => context.go('/home'),
                ),
                const Expanded(
                  child: Text('Pembayaran',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.storefront_outlined, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text('TokoBelanja',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                children: [
                  // Order items
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('Pesanan #TB-2026-88142',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate400,
                              )),
                        ),
                        ...items.asMap().entries.map((e) {
                          final i = e.key;
                          final item = e.value;
                          return Column(
                            children: [
                              if (i > 0) const Divider(height: 1, color: AppColors.line2),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1E9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 22, color: _orange)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'] as String,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.ink,
                                              )),
                                          Text(
                                              '${item['qty']} × ${CurrencyFormatter.format(item['price'] as double)}',
                                              style: const TextStyle(fontSize: 12.5, color: AppColors.slate400)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format((item['price'] as double) * (item['qty'] as int)),
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Payment method
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Metode pembayaran',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                          )),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                      border: Border.all(color: AppColors.primaryLight, width: 1.8),
                    ),
                    child: Row(
                      children: [
                        const AppLogo(size: 40),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dompet Kampus Global',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  )),
                              Text('Saldo · pembayaran instan',
                                  style: TextStyle(fontSize: 12.5, color: AppColors.slate400)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_rounded, size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Totals
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      children: [
                        _TotalLine(label: 'Subtotal', value: CurrencyFormatter.format(subtotal)),
                        const Divider(height: 1, color: AppColors.line2),
                        _TotalLine(label: 'Ongkos kirim', value: CurrencyFormatter.format(ship)),
                        const Divider(height: 1, color: AppColors.line2),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate600,
                                  )),
                              Text(CurrencyFormatter.format(total),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: _orange,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pay bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
            child: AppButton(
              label: 'Bayar ${CurrencyFormatter.format(total)}',
              onPressed: () => context.go('/pin', extra: {
                'kind': 'deeplink',
                'description': 'TokoBelanja #TB-2026-88142',
                'amount': total,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  const _TotalLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.slate500, fontFamily: 'PlusJakartaSans')),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'PlusJakartaSans')),
        ],
      ),
    );
  }
}
