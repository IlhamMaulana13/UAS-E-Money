import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool light;
  final bool withText;

  const AppLogo({super.key, this.size = 56, this.light = false, this.withText = false});

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'PlusJakartaSans';

    Widget icon = Image.asset(
      'assets/images/logo-dompet.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!withText) return icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dompet Kampus',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w800,
                color: light ? Colors.white : AppColors.ink,
                letterSpacing: -0.3,
                height: 1.05,
              ),
            ),
            Text(
              'GLOBAL',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: size * 0.205,
                fontWeight: FontWeight.w700,
                color: light ? Colors.white.withValues(alpha: 0.85) : AppColors.primary,
                letterSpacing: 1.5,
                height: 1.05,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
