import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SuccessCheck extends StatefulWidget {
  final double size;
  final String tone;

  const SuccessCheck({super.key, this.size = 92, this.tone = 'green'});

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<SuccessCheck> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _checkDraw;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.elasticOut));
    _checkDraw = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 0.9, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.tone == 'green' ? AppColors.green : AppColors.primary;
    final bgColor = widget.tone == 'green' ? AppColors.greenSurface : AppColors.primarySurface;

    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
              ),
            ),
            // Inner circle with check
            Container(
              width: widget.size * 0.66,
              height: widget.size * 0.66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _checkDraw,
                  builder: (_, __) => CustomPaint(
                    size: Size(widget.size * 0.36, widget.size * 0.36),
                    painter: _CheckPainter(progress: _checkDraw.value),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final s = size.width / 24;
    final path = Path()
      ..moveTo(5 * s, 12.5 * s)
      ..lineTo(10 * s, 17.5 * s)
      ..lineTo(19.5 * s, 7 * s);

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
