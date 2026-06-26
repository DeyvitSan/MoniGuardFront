import 'package:flutter/material.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, _buildDot),
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = index == currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        //Dot activo: píldora larga; inactivo: círculo pequeño
        width: isActive ? 28.0 : 8.0,
        height: 8.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}