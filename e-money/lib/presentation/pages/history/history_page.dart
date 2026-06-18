import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/account/account_bloc.dart';
import '../../widgets/transaction_row.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _tab = 'all';

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Riwayat',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 16),
                Row(
                  children: [['all', 'Semua'], ['out', 'Pengeluaran'], ['in', 'Pemasukan']]
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _tab = t[0]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _tab == t[0] ? AppColors.primary : AppColors.bg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(t[1],
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _tab == t[0] ? Colors.white : AppColors.slate500,
                                    )),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.line2),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (state is AccountError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: AppColors.slate400)));
                }
                if (state is AccountLoaded) {
                  List<TransactionEntity> txns = state.transactions;
                  if (_tab == 'in') txns = txns.where((t) => t.isCredit).toList();
                  if (_tab == 'out') txns = txns.where((t) => !t.isCredit).toList();

                  if (txns.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada transaksi',
                          style: TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.slate400)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: txns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (_, i) {
                      return i == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 4, bottom: 10),
                                  child: Text('Hari ini',
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
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppColors.shadowSoft,
                                  ),
                                  child: Column(
                                    children: txns
                                        .asMap()
                                        .entries
                                        .map((e) => TransactionRow(txn: e.value, divider: e.key > 0))
                                        .toList(),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
