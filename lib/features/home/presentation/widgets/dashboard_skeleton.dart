import 'package:flutter/material.dart';

class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final color = cs.onSurface.withValues(alpha: _anim.value * 0.12);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Box(w: 120, h: 14, color: color),
                    const SizedBox(height: 8),
                    _Box(w: 200, h: 22, color: color),
                    const SizedBox(height: 6),
                    _Box(w: 150, h: 12, color: color),
                  ],
                ),
              ),
              _Box(w: 68, h: 68, color: color, radius: 16),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _Box(h: 110, color: color, radius: 24)),
              const SizedBox(width: 12),
              Expanded(child: _Box(h: 110, color: color, radius: 24)),
              const SizedBox(width: 12),
              Expanded(child: _Box(h: 110, color: color, radius: 24)),
            ]),
            const SizedBox(height: 16),
            _Box(h: 130, color: color, radius: 24),
            const SizedBox(height: 12),
            _Box(h: 72, color: color, radius: 24),
          ],
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  final double? w;
  final double  h;
  final Color   color;
  final double  radius;
  const _Box({this.w, required this.h, required this.color, this.radius = 8});

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}