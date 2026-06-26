// lib/core/utils/validators.dart
// SRP: Única responsabilidad — validar inputs de formularios.
// Funciones puras, sin estado, sin dependencias de Flutter/UI.
// Reutilizables en cualquier formulario del proyecto.

abstract final class AppValidators {
  //Regex RFC 5322 simplificado — cubre 99.9% de emails reales
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Valida formato de correo electrónico.
  /// Retorna `null` si es válido, mensaje de error si no.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  /// Valida contraseña con longitud mínima configurable.
  /// Por defecto: 8 caracteres (OWASP mínimo recomendado).
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < minLength) {
      return 'Mínimo $minLength caracteres';
    }
    return null;
  }

  /// Valida que un campo no esté vacío.
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre completo es obligatorio';
    }
    // Opcional: Validar que al menos ponga un nombre y un apellido
    if (value.trim().split(' ').length < 2) {
      return 'Ingresa al menos tu nombre y un apellido';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Debes confirmar tu contraseña';
    }
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}