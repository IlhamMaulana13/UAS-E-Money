import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../widgets/feature_icon.dart';

class TwoFANotifPage extends StatefulWidget {
  final String mode;
  const TwoFANotifPage({super.key, this.mode = 'login'});
  @override
  State<TwoFANotifPage> createState() => _TwoFANotifPageState();
}

class _TwoFANotifPageState extends State<TwoFANotifPage> {
  String _phase = 'waiting'; // waiting, approved

  @override
  void initState() {
    super.initState();
    context.read<OtpBloc>().add(OtpSendFirebase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          setState(() => _phase = 'approved');
          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted) context.go('/home');
          });
        } else if (state is OtpError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
                  onPressed: () => context.go(widget.mode == 'setup' ? '/setup-2fa' : '/login'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      FeatureIcon(
                        icon: _phase == 'approved'
                            ? Icons.verified_user_outlined
                            : Icons.notifications_outlined,
                        tone: 'green',
                        size: 82,
                        iconSize: 40,
                      ),
                      const SizedBox(height: 26),
                      Text(
                        _phase == 'approved' ? 'Disetujui!' : 'Cek notifikasi kamu',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _phase == 'approved'
                            ? 'Identitas terverifikasi. Mengarahkan…'
                            : 'Kami mengirim notifikasi ke perangkatmu. Ketuk "Setujui" untuk melanjutkan.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.5,
                          color: AppColors.slate500,
                          height: 1.55,
                        ),
                      ),
                      if (_phase == 'waiting') ...[
                        const SizedBox(height: 34),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(AppColors.green),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Menunggu persetujuan…',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13.5,
                                  color: AppColors.slate400,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ],
                      const Spacer(),
                      const Text(
                        'Tidak menerima notifikasi? Kirim ulang',
                        style: TextStyle(fontSize: 12.5, color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
