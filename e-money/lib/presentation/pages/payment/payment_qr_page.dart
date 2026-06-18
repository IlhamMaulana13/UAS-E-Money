import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feature_icon.dart';

class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key});
  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage> {
  bool _detected = false;
  bool _sheetShown = false;
  final _controller = MobileScannerController();

  // Mock merchant data for demo
  final _merchant = {'name': 'Kantin Teknik UI', 'sub': 'NMID: ID2024088123 · QRIS', 'amount': 27000.0};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_detected) {
      setState(() => _detected = true);
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(
        child: Stack(
          children: [
            // Camera
            MobileScanner(controller: _controller, onDetect: _onDetect),
            // Overlay
            _buildOverlay(),
            // Header
            _buildHeader(),
            // Detected sheet
            if (_detected && !_sheetShown)
              _buildDetectedSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              onPressed: () => context.go('/home'),
            ),
            const Expanded(
              child: Text('Scan QRIS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  )),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Viewfinder
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                ),
              ),
              // Corner brackets
              ...[[0, 0], [1, 0], [0, 1], [1, 1]].map((corner) => Positioned(
                    top: corner[1] == 0 ? 0 : null,
                    bottom: corner[1] == 1 ? 0 : null,
                    left: corner[0] == 0 ? 0 : null,
                    right: corner[0] == 1 ? 0 : null,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border(
                          top: corner[1] == 0 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                          bottom: corner[1] == 1 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                          left: corner[0] == 0 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                          right: corner[0] == 1 ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: corner[0] == 0 && corner[1] == 0 ? const Radius.circular(6) : Radius.zero,
                          topRight: corner[0] == 1 && corner[1] == 0 ? const Radius.circular(6) : Radius.zero,
                          bottomLeft: corner[0] == 0 && corner[1] == 1 ? const Radius.circular(6) : Radius.zero,
                          bottomRight: corner[0] == 1 && corner[1] == 1 ? const Radius.circular(6) : Radius.zero,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _detected ? Icons.check_rounded : null,
                color: AppColors.green,
                size: 16,
              ),
              if (_detected) const SizedBox(width: 8),
              Text(
                _detected ? 'Kode terdeteksi' : 'Arahkan kamera ke kode QRIS',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['Bayar', 'QR Saya'].map((label) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        label == 'Bayar' ? Icons.qr_code_rounded : Icons.qr_code_2_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(label,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedSheet() {
    final amount = _merchant['amount'] as double;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
          child: Column(
            children: [
              Container(width: 42, height: 5, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 16),
              Row(
                children: [
                  const FeatureIcon(icon: Icons.storefront_outlined, tone: 'violet', size: 52, iconSize: 26),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_merchant['name'] as String,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            )),
                        Text(_merchant['sub'] as String,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.slate400)),
                      ],
                    ),
                  ),
                  const AppBadge(label: 'QRIS', tone: 'violet'),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Total tagihan', style: TextStyle(fontSize: 13, color: AppColors.slate400)),
              const SizedBox(height: 4),
              Text(CurrencyFormatter.format(amount),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.6,
                  )),
              const SizedBox(height: 18),
              AppButton(
                label: 'Bayar Sekarang',
                icon: const Icon(Icons.lock_outline_rounded, size: 19, color: Colors.white),
                onPressed: () {
                  setState(() => _sheetShown = true);
                  context.go('/pin', extra: {
                    'kind': 'payment',
                    'description': 'Pembayaran ${_merchant['name']}',
                    'amount': amount,
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
