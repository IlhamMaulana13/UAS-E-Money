import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/auth/send_otp_usecase.dart';
import '../../../domain/usecases/auth/verify_email_otp_usecase.dart';
import '../../../injection/injection_container.dart';
import '../../widgets/code_input.dart';
import '../../widgets/feature_icon.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  String _code = '';
  int _timer = 60;
  bool _hasError = false;
  bool _loading = false;
  String? _errorMessage;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdown?.cancel();
    setState(() => _timer = 60);
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timer <= 0) {
        t.cancel();
      } else {
        setState(() => _timer--);
      }
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() {
      _code = value;
      _hasError = false;
      _errorMessage = null;
    });
    if (value.length == 6) {
      _verify(value);
    }
  }

  Future<void> _verify(String code) async {
    setState(() => _loading = true);
    try {
      await sl<VerifyEmailOtpUsecase>()(code);
      if (mounted) context.go('/setup-2fa');
    } on ServerFailure catch (e) {
      final isInvalidOtp = e.errorCode == 'INVALID_OTP';
      setState(() {
        _hasError = true;
        _errorMessage = isInvalidOtp ? 'Kode salah atau sudah kadaluarsa' : e.message;
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() { _code = ''; _hasError = false; });
      });
    } catch (_) {
      setState(() { _hasError = true; _errorMessage = 'Terjadi kesalahan, coba lagi'; });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() { _code = ''; _hasError = false; });
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await sl<SendOtpEmailUsecase>()();
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode OTP baru telah dikirim ke email kamu'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal kirim ulang, coba lagi'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'email kamu';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(DkgIcons.arrowLeft, color: AppColors.ink),
                onPressed: () => context.go('/register'),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 28),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Icon(DkgIcons.mail, size: 36, color: AppColors.primary),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(DkgIcons.check, size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Verifikasi email',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Kami kirim kode 6 digit ke\n',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.5,
                          color: AppColors.slate500,
                          height: 1.55,
                        ),
                        children: [
                          TextSpan(
                            text: email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      transform: _hasError
                          ? (Matrix4.identity()..translateByDouble(10.0, 0, 0, 1.0))
                          : Matrix4.identity(),
                      child: CodeInput(
                        value: _code,
                        onChanged: _loading ? (_) {} : _onCodeChanged,
                        hasError: _hasError,
                      ),
                    ),
                    if (_loading) ...[
                      const SizedBox(height: 16),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ] else if (_hasError && _errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: AppColors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    _timer > 0
                        ? Text(
                            'Kirim ulang kode dalam 00:${_timer.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13.5,
                              color: AppColors.slate400,
                            ),
                          )
                        : TextButton.icon(
                            onPressed: _resend,
                            icon: const Icon(DkgIcons.refresh, size: 16, color: AppColors.primary),
                            label: const Text(
                              'Kirim ulang kode',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
