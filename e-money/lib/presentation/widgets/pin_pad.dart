import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PinPad extends StatelessWidget {
  final String value;
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onComplete;

  const PinPad({
    super.key,
    required this.value,
    required this.onChanged,
    this.length = 6,
    this.onComplete,
  });

  void _press(String key) {
    String next;
    if (key == 'del') {
      next = value.isEmpty ? '' : value.substring(0, value.length - 1);
    } else {
      if (value.length >= length) return;
      next = value + key;
    }
    onChanged(next);
    if (next.length == length) {
      Future.delayed(const Duration(milliseconds: 140), () => onComplete?.call(next));
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'bio', '0', 'del'];

    return Column(
      children: [
        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(length, (i) {
            final filled = i < value.length;
            return Container(
              width: 15,
              height: 15,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: filled ? AppColors.primary : AppColors.primaryBorder,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
        // Keypad grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: keys.map((k) {
            if (k == 'bio') {
              return _KeyButton(
                onTap: () => onComplete?.call(value),
                child: const Icon(Icons.fingerprint_rounded, size: 28, color: AppColors.primary),
              );
            }
            if (k == 'del') {
              return _KeyButton(
                onTap: () => _press('del'),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 22, color: AppColors.slate600),
              );
            }
            return _KeyButton(
              onTap: () => _press(k),
              child: Text(
                k,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _KeyButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.shadowSoft,
        ),
        child: Center(child: child),
      ),
    );
  }
}
