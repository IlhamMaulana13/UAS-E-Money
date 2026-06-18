import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feature_icon.dart';

const _twoFaMethods = [
  _TwoFaMethod(
    key: 'smtp',
    icon: DkgIcons.mail,
    tone: 'blue',
    title: 'Email OTP (SMTP)',
    desc: 'Kode 6 digit dikirim ke email kamu setiap kali masuk.',
    route: '/2fa/smtp',
  ),
  _TwoFaMethod(
    key: 'totp',
    icon: DkgIcons.smartphone,
    tone: 'violet',
    title: 'Authenticator (TOTP)',
    desc: 'Kode berubah tiap 30 detik di Google Authenticator / Authy.',
    route: '/2fa/totp',
    badge: 'Paling aman',
  ),
  _TwoFaMethod(
    key: 'notif',
    icon: DkgIcons.bell,
    tone: 'green',
    title: 'Notifikasi OTP',
    desc: 'Setujui permintaan masuk lewat notifikasi di HP kamu.',
    route: '/2fa/notif',
  ),
];

class _TwoFaMethod {
  final String key;
  final IconData icon;
  final String tone;
  final String title;
  final String desc;
  final String route;
  final String? badge;
  const _TwoFaMethod({
    required this.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.desc,
    required this.route,
    this.badge,
  });
}

class Setup2FAPage extends StatefulWidget {
  const Setup2FAPage({super.key});
  @override
  State<Setup2FAPage> createState() => _Setup2FAPageState();
}

class _Setup2FAPageState extends State<Setup2FAPage> {
  String _selected = 'smtp';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(DkgIcons.arrowLeft, color: AppColors.ink),
                onPressed: () => context.canPop() ? context.pop() : context.go('/akun'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Icon(DkgIcons.shieldCheck, size: 30, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Amankan akunmu',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.4,
                      )),
                  const SizedBox(height: 7),
                  const Text(
                    'Pilih metode verifikasi 2 langkah (2FA). Kamu bisa ganti kapan saja di Pengaturan.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.5,
                      color: AppColors.slate500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
                children: _twoFaMethods.map((m) {
                  final on = _selected == m.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = m.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 13),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: on ? AppColors.primarySurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: on ? AppColors.primaryLight : AppColors.line,
                          width: 1.8,
                        ),
                        boxShadow: on
                            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 0, spreadRadius: 4)]
                            : [],
                      ),
                      child: Row(
                        children: [
                          FeatureIcon(icon: m.icon, tone: m.tone),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(m.title,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          )),
                                    ),
                                    if (m.badge != null) ...[
                                      const SizedBox(width: 7),
                                      AppBadge(label: m.badge!, tone: 'green'),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(m.desc,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.8,
                                      color: AppColors.slate500,
                                      height: 1.45,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: on ? AppColors.primary : Colors.white,
                              border: Border.all(
                                color: on ? AppColors.primary : AppColors.line,
                                width: 2,
                              ),
                            ),
                            child: on
                                ? Center(
                                    child: Container(
                                      width: 9,
                                      height: 9,
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
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 22),
              child: AppButton(
                label: 'Lanjutkan',
                onPressed: () {
                  final m = _twoFaMethods.firstWhere((m) => m.key == _selected);
                  context.go(m.route, extra: {'mode': 'setup'});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
