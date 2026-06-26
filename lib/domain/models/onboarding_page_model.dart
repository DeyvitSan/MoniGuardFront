import 'package:flutter/material.dart';

@immutable
class OnboardingPageModel {
  final String tag;          // e.g. "01 • ENTORNO"
  final String title;        // e.g. "Monitoreo Climático"
  final String description;  // párrafo de apoyo
  final IconData icon;       // ícono principal de la página
  final Color accentColor;   // color de énfasis para el ícono/decoración

  const OnboardingPageModel({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}