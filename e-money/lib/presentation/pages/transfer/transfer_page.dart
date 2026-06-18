import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/feature_icon.dart';

const _contacts = [
  {'id': '1', 'name': 'Budi Santoso', 'sub': '0812-3456-7890', 'fav': true},
  {'id': '2', 'name': 'Citra Dewi', 'sub': '0856-1122-3344', 'fav': true},
  {'id': '3', 'name': 'Eko Prasetyo', 'sub': '0813-9988-7766', 'fav': false},
  {'id': '4', 'name': 'Fitri Handayani', 'sub': '0821-4455-6677', 'fav': false},
  {'id': '5', 'name': 'Gilang Ramadhan', 'sub': '0857-3344-1122', 'fav': false},
];

const _banks = [
  {'id': 'bca', 'name': 'BCA', 'sub': 'Bank Central Asia', 'tone': 'blue'},
  {'id': 'bni', 'name': 'BNI', 'sub': 'Bank Negara Indonesia', 'tone': 'amber'},
  {'id': 'mandiri', 'name': 'Mandiri', 'sub': 'Bank Mandiri', 'tone': 'blue'},
  {'id': 'bri', 'name': 'BRI', 'sub': 'Bank Rakyat Indonesia', 'tone': 'blue'},
];

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});
  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String _tab = 'dkg';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppTopBar(title: 'Transfer', onBack: () => context.go('/home')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [['dkg', 'Sesama DKG'], ['bank', 'Ke Bank']].map((t) {
                    final active = _tab == t[0];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { _tab = t[0]; _q = ''; }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(t[1],
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : AppColors.slate500,
                                )),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                AppField(
                  value: _q,
                  onChanged: (v) => setState(() => _q = v),
                  placeholder: _tab == 'dkg' ? 'Cari nama / nomor HP' : 'Cari bank',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.line2),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _tab == 'dkg' ? _buildContacts() : _buildBanks(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContacts() {
    final filtered = _contacts.where((c) =>
        (c['name'] as String).toLowerCase().contains(_q.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 10, bottom: 8),
          child: Text('Kontak favorit',
              style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate400)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.shadowSoft,
          ),
          child: Column(
            children: filtered.asMap().entries.map((e) {
              final i = e.key;
              final c = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, indent: 16, color: AppColors.line2),
                  GestureDetector(
                    onTap: () => context.go('/transfer/amount', extra: {
                      'recipient': c,
                      'channel': 'dkg',
                    }),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                      child: Row(
                        children: [
                          AppAvatar(name: c['name'] as String, size: 44),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['name'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    )),
                                Text(c['sub'] as String,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.slate400)),
                              ],
                            ),
                          ),
                          if (c['fav'] as bool)
                            const Icon(Icons.star_rounded, size: 18, color: AppColors.amber),
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
    );
  }

  Widget _buildBanks() {
    final filtered = _banks.where((b) =>
        (b['sub'] as String).toLowerCase().contains(_q.toLowerCase()) ||
        (b['name'] as String).toLowerCase().contains(_q.toLowerCase())).toList();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.shadowSoft,
      ),
      child: Column(
        children: filtered.asMap().entries.map((e) {
          final i = e.key;
          final b = e.value;
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, indent: 16, color: AppColors.line2),
              GestureDetector(
                onTap: () => context.go('/transfer/amount', extra: {
                  'recipient': b,
                  'channel': 'bank',
                }),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(b['name'] as String,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontSize: 14,
                              )),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b['sub'] as String,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                )),
                            const Text('Biaya Rp2.500',
                                style: TextStyle(fontSize: 12.5, color: AppColors.slate400)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.slate400),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
