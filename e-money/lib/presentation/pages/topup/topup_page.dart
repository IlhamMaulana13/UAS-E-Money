import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/feature_icon.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});
  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  double _amount = 100000;
  String _method = 'bca';

  final _chips = [50000.0, 100000.0, 200000.0, 500000.0, 1000000.0];
  final _methods = [
    {'id': 'bca', 'name': 'BCA Virtual Account', 'tone': 'blue', 'icon': Icons.account_balance_outlined},
    {'id': 'card', 'name': 'Kartu Debit/Kredit', 'tone': 'violet', 'icon': Icons.credit_card_outlined},
    {'id': 'alfa', 'name': 'Alfamart / Indomaret', 'tone': 'red', 'icon': Icons.storefront_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentTopupSuccess) {
          context.go('/success', extra: {
            'title': 'Top up berhasil',
            'subtitle': 'Saldo kamu bertambah',
            'amount': state.amount,
            'lines': [
              ['Metode', _methodName()],
              ['Saldo sekarang', CurrencyFormatter.format(state.balance)],
            ],
          });
        } else if (state is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppTopBar(title: 'Isi Saldo', onBack: () => context.go('/home')),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('Nominal top up',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                          )),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: _chips.map((c) {
                        final selected = _amount == c;
                        return GestureDetector(
                          onTap: () => setState(() => _amount = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primarySurface : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected ? AppColors.primaryLight : AppColors.line,
                                width: 1.8,
                              ),
                            ),
                            child: Center(
                              child: Text(CurrencyFormatter.format(c),
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: selected ? AppColors.primary : AppColors.ink,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('Metode pembayaran',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                          )),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppColors.shadowSoft,
                      ),
                      child: Column(
                        children: _methods.asMap().entries.map((entry) {
                          final i = entry.key;
                          final m = entry.value;
                          final selected = _method == m['id'];
                          return Column(
                            children: [
                              if (i > 0) const Divider(height: 1, indent: 16, color: AppColors.line2),
                              GestureDetector(
                                onTap: () => setState(() => _method = m['id'] as String),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      FeatureIcon(icon: m['icon'] as IconData, tone: m['tone'] as String, size: 42, iconSize: 20),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Text(m['name'] as String,
                                            style: const TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.ink,
                                            )),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selected ? AppColors.primary : Colors.white,
                                          border: Border.all(
                                            color: selected ? AppColors.primary : AppColors.line,
                                            width: 2,
                                          ),
                                        ),
                                        child: selected
                                            ? Center(
                                                child: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.bg,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) => AppButton(
                  label: 'Top Up ${CurrencyFormatter.format(_amount)}',
                  isLoading: state is PaymentLoading,
                  onPressed: () {
                    context.read<PaymentBloc>().add(PaymentTopupRequested(_amount));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _methodName() {
    return _methods.firstWhere((m) => m['id'] == _method)['name'] as String;
  }
}
