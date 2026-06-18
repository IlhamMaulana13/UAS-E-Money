import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/account/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';
import '../../widgets/transaction_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountLoadRequested());
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final firstName = user?.firstName ?? 'Kamu';
        final fullName = user?.name ?? 'User';

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              final balance = accountState is AccountLoaded ? accountState.account.balance : 0.0;
              final txns =
                  accountState is AccountLoaded ? accountState.transactions : <TransactionEntity>[];
              final loading = accountState is AccountLoading;

              return RefreshIndicator(
                onRefresh: () async => context.read<AccountBloc>().add(AccountRefreshRequested()),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Gradient header
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                            20, MediaQuery.of(context).padding.top + 12, 20, 94),
                        child: Row(
                          children: [
                            AppAvatar(
                                name: fullName,
                                size: 44,
                                bg: Colors.white.withValues(alpha: 0.25)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selamat siang,',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 13,
                                        color: Colors.white70,
                                      )),
                                  Text('$firstName ',
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      )),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.notifications_outlined,
                                      size: 21, color: Colors.white),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 11,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.amber,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Balance Card (overlaps the header's bottom edge)
                      Transform.translate(
                        offset: const Offset(0, -46),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildBalanceCard(balance, loading),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildPointsRow(),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildFeatureGrid(),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildDeeplinkBanner(),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildTransactions(txns),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(double balance, bool loading) {
    final actions = [
      {'icon': Icons.north_rounded, 'label': 'Top Up', 'tone': 'blue', 'route': '/topup'},
      {'icon': Icons.send_rounded, 'label': 'Transfer', 'tone': 'green', 'route': '/transfer'},
      {'icon': Icons.qr_code_rounded, 'label': 'Bayar', 'tone': 'violet', 'route': '/payment'},
      {'icon': Icons.south_rounded, 'label': 'Tarik', 'tone': 'amber', 'route': '/topup'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.shadowCard,
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  const AppLogo(size: 26),
                  const SizedBox(width: 7),
                  const Text('Saldo DKG',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate500,
                      )),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/topup'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
                      SizedBox(width: 5),
                      Text('Isi Saldo',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _hideBalance ? CurrencyFormatter.maskBalance() : CurrencyFormatter.format(balance),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(_hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20, color: AppColors.slate400),
                onPressed: () => setState(() => _hideBalance = !_hideBalance),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line2)),
            ),
            child: Row(
              children: actions.map((a) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(a['route'] as String),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          FeatureIcon(
                            icon: a['icon'] as IconData,
                            tone: a['tone'] as String,
                            size: 46,
                            iconSize: 22,
                          ),
                          const SizedBox(height: 7),
                          Text(a['label'] as String,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate600,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.shadowSoft,
            ),
            child: Row(
              children: [
                const FeatureIcon(
                    icon: Icons.star_outline_rounded, tone: 'amber', size: 38, iconSize: 19),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Poin Kampus',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w600)),
                    Text('1.250',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.shadowSoft,
            ),
            child: Row(
              children: [
                const FeatureIcon(
                    icon: Icons.qr_code_rounded, tone: 'green', size: 38, iconSize: 19),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('KTM Digital',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w600)),
                    Text('Aktif',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.smartphone_outlined, 'label': 'Pulsa', 'tone': 'blue'},
      {'icon': Icons.bolt_outlined, 'label': 'PLN', 'tone': 'amber'},
      {'icon': Icons.restaurant_outlined, 'label': 'Kantin', 'tone': 'red'},
      {'icon': Icons.receipt_long_outlined, 'label': 'UKT', 'tone': 'violet'},
      {'icon': Icons.wifi_rounded, 'label': 'Paket Data', 'tone': 'green'},
      {'icon': Icons.card_giftcard_rounded, 'label': 'Voucher', 'tone': 'red'},
      {'icon': Icons.favorite_outline_rounded, 'label': 'Donasi', 'tone': 'amber'},
      {'icon': Icons.more_horiz_rounded, 'label': 'Lainnya', 'tone': 'slate'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowSoft,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 18,
        crossAxisSpacing: 0,
        children: features.map((f) {
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureIcon(
                    icon: f['icon'] as IconData, tone: f['tone'] as String, size: 50, iconSize: 24),
                const SizedBox(height: 8),
                Text(f['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate600,
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeeplinkBanner() {
    return GestureDetector(
      onTap: () => context.go('/merchant'),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1726), Color(0xFF21314D)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5B9BFF).withValues(alpha: 0.18),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.link_rounded, size: 24, color: Color(0xFF5B9BFF)),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coba bayar dari toko online',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                      SizedBox(height: 2),
                      Text('Simulasi checkout e-commerce → bayar via DKG',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12.5,
                            color: Colors.white70,
                          )),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(List<TransactionEntity> txns) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Transaksi terakhir',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            GestureDetector(
              onTap: () => context.go('/history'),
              child: const Text('Lihat semua',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.shadowSoft,
          ),
          child: txns.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('Belum ada transaksi',
                        style: TextStyle(color: AppColors.slate400, fontFamily: 'PlusJakartaSans')),
                  ),
                )
              : Column(
                  children: txns
                      .take(4)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => TransactionRow(txn: e.value, divider: e.key > 0))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
