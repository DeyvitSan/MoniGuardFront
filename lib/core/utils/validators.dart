abstract final class AppValidators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );
  // Retorna `null` si es válido, mensaje de error si no.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido';
    }
    return null;
  }
  // Mínimo 8 caracteres (OWASP) + mayúscula, minúscula y número.
  // Debe coincidir con la política validada en el backend
  // (api-gateway/src/auth/dto/gateway-auth.dto.ts) — la validación de
  // cliente es solo para dar feedback rápido, nunca la única barrera.
  static final RegExp _passwordComplexity =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < minLength) {
      return 'Mínimo $minLength caracteres';
    }
    if (!_passwordComplexity.hasMatch(value)) {
      return 'Debe incluir mayúscula, minúscula y número';
    }
    return null;
  }

  // Para el formulario de login NO se exige complejidad — solo que no esté
  // vacío. Evita bloquear el acceso a cuentas creadas antes de esta regla.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    return null;
  }

  //Valida que un campo no esté vacío.
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