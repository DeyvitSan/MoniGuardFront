# moniguard

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Build de producción (seguridad)

Siempre compila los releases que se publican en la Play Store con:

```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=API_BASE_URL=https://TU_DOMINIO_REAL/api/v1
```

- `--obfuscate` + `--split-debug-info`: ofusca nombres de clases/símbolos en
  el binario (checklist #19). Guarda la carpeta `build/debug-info` fuera del
  repo — la necesitas para poder leer stack traces de crashes en producción,
  pero si se pierde no puedes des-ofuscar reportes viejos.
- `--dart-define=API_BASE_URL=...`: nunca dependas del `defaultValue` de
  `ApiConstants.baseUrl` para producción; ese valor es solo un placeholder.
- Para desarrollo local contra el backend en tu red LAN, usa
  `flutter run --dart-define=API_BASE_URL=http://TU_IP_LOCAL:3000/api/v1`.
