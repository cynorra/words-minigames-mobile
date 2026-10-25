import 'package:flutter/material.dart';

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradientColors;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradientColors,
  });
}
