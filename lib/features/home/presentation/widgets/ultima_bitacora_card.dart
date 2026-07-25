import 'package:flutter/material.dart';

class UltimaBitacoraCard extends StatelessWidget {
  final DateTime? fecha;
  final VoidCallback? onTap;

  const UltimaBitacoraCard({super.key, this.fecha, this.onTap});

  String get _fechaTexto {
    if (fecha == null) return 'Sin registros';
    final diff = DateTime.now().difference(fecha!);
    if (diff.inMinutes < 60)  return 'Hace ${diff.inMinutes} min';
    if (diff.inHours   < 24)  return 'Hace ${diff.inHours} h';
    if (diff.inDays    == 1)  return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.secondaryContainer,
          ),
          child: Icon(Icons.edit_note_rounded, color: cs.secondary, size: 22),
        ),
        title: Text('Última bitácora',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(_fechaTexto,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: cs.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}