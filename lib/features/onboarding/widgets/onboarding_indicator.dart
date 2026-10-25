import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) => _buildDot(index)),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == currentPage;
    final isPast = index < currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: AppConstants.smallSpacing / 2),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color:
            isActive || isPast
                ? activeColor
                : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
    );
  }
}
