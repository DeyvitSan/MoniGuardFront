import 'package:flutter/material.dart';

@immutable
class OnboardingPageModel {
  final String tag;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingPageModel({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}