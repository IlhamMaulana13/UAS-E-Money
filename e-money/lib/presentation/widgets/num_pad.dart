import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NumPad extends StatelessWidget {
  final ValueChanged<String> onKey;

  const NumPad({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'del'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: keys.map((k) {
        Widget child;
        if (k == 'del') {
          child = const Icon(Icons.arrow_back_ios_rounded, size: 22, color: AppColors.slate600);
        } else {
          child = Text(
            k,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: k == '000' ? 20 : 24,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          );
        }
        return GestureDetector(
          onTap: () => onKey(k),
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: child),
          ),
        );
      }).toList(),
    );
  }
}
