// features/analisis/presentation/pages/analisis_page.dart
// Pantalla dedicada al diagnóstico real de MoniGuard: combina el riesgo
// climático (predicción anticipada) con la evidencia de campo reciente
// (análisis de texto de bitácoras), y presenta un veredicto único con
// su razonamiento — no es un extra, es el coraz
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../bitacora/domain/bitacora_repository.dart';
import '../../../bitacora/domain/entities/bitacora.dart';
import '../../../home/domain/entities/dashboard_summary.dart';
import '../provider/analisis_provider.dart';

class AnalisisPage extends StatelessWidget {
  const AnalisisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AnalisisProvider>(
      create: (_) => getIt<AnalisisProvider>()..cargar(),
      child: const _AnalisisView(),
    );
  }
}

class _AnalisisView extends StatelessWidget {
  const _AnalisisView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<AnalisisProvider>(
      builder: (context, ctrl, _) {
        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ctrl.refresh(),
              child: switch (ctrl.status) {
                AnalisisStatus.idle || AnalisisStatus.loading =>
                    _buildLoading(),
                AnalisisStatus.failure => _buildError(context, cs, ctrl),
                AnalisisStatus.success => _buildContent(context, cs, ctrl),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView(
      children: const [
        SizedBox(height: 200),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 16),
        Center(child: Text('Calculando diagnóstico...')),
      ],
    );
  }

  Widget _buildError(BuildContext context, ColorScheme cs, AnalisisProvider ctrl) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.cloud_off_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            ctrl.errorMessage ?? 'No se pudo cargar el diagnóstico.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: ctrl.refresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme cs, AnalisisProvider ctrl) {
    final summary = ctrl.summary!;
    final analisis = summary.analisisCombinado;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Diagnóstico',
            style: AppTypography.playfair(size: 26, color: cs.onSurface)),
        const SizedBox(height: 4),
        Text(
          summary.parcela.nombre,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 24),

        if (analisis == null)
          _buildSinAnalisis(cs)
        else ...[
          _buildVeredictoHero(cs, analisis),
          const SizedBox(height: 24),
          Text('¿DE DÓNDE SALE ESTE RESULTADO?',
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          _buildFuenteCard(
            cs,
            icono: Icons.cloud_outlined,
            titulo: 'Clima actual',
            subtitulo: 'Predicción climática (Inteligencia Artificial)',
            valor: analisis.fuenteClima.nivel.label,
            peso: analisis.fuenteClima.peso,
            colorNivel: _colorPorNivel(analisis.fuenteClima.nivel, cs),
          ),
          const SizedBox(height: 12),
          _buildFuenteCard(
            cs,
            icono: Icons.edit_note_rounded,
            titulo: 'Observaciones de campo',
            subtitulo: analisis.fuenteCampo.bitacorasAnalizadas > 0
                ? '${analisis.fuenteCampo.bitacorasAnalizadas} bitácora(s) reciente(s) analizada(s)'
                : 'Sin bitácoras recientes con análisis',
            valor: analisis.fuenteCampo.etiquetaPredominante ?? 'Sin datos',
            peso: analisis.fuenteCampo.peso,
            colorNivel: cs.secondary,
          ),
          const SizedBox(height: 24),
          _buildRecomendacion(cs, analisis),
          const SizedBox(height: 32),
          _buildBotonExportar(context, summary, analisis),
          const SizedBox(height: 28),
          Text('BITÁCORAS ANALIZADAS RECIENTEMENTE',
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          const _BitacorasRecientesSection(),
        ],
      ],
    );
  }

  Widget _buildSinAnalisis(ColorScheme cs) {
    return Card(
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Aún no hay suficiente información para un diagnóstico completo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorPorNivel(NivelRiesgo nivel, ColorScheme cs) {
    switch (nivel) {
      case NivelRiesgo.bajo: return AppColors.forestDeep;
      case NivelRiesgo.medio: return AppColors.warning;
      case NivelRiesgo.alto: return cs.error;
      case NivelRiesgo.desconocido: return cs.onSurfaceVariant;
    }
  }

  Widget _buildVeredictoHero(ColorScheme cs, AnalisisCombinado analisis) {
    final color = _colorPorNivel(analisis.veredicto, cs);
    final bg = analisis.veredicto == NivelRiesgo.bajo
        ? AppColors.emeraldPale
        : analisis.veredicto == NivelRiesgo.medio
        ? const Color(0xFFFFF3E0)
        : cs.errorContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text('RIESGO DE MONILIASIS',
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text(
            analisis.veredicto.label.toUpperCase(),
            style: AppTypography.playfair(size: 40, weight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 8),
          Text('${analisis.porcentaje}%',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildFuenteCard(
      ColorScheme cs, {
        required IconData icono,
        required String titulo,
        required String subtitulo,
        required String valor,
        required double peso,
        required Color colorNivel,
      }) {
    return Card(
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colorNivel.withValues(alpha: 0.15)),
              child: Icon(icono, color: colorNivel, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitulo, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(valor,
                    style: TextStyle(fontWeight: FontWeight.w700, color: colorNivel)),
                Text('${(peso * 100).round()}% del peso',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacion(ColorScheme cs, AnalisisCombinado analisis) {
    return Card(
      color: cs.secondaryContainer,
      shape: AppShapes.cardShape,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: cs.onSecondaryContainer, size: 20),
                const SizedBox(width: 8),
                Text('Recomendación',
                    style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSecondaryContainer)),
              ],
            ),
            const SizedBox(height: 10),
            Text(analisis.recomendacion,
                style: TextStyle(color: cs.onSecondaryContainer, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonExportar(
      BuildContext context, DashboardSummary summary, AnalisisCombinado analisis) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _verPdf(context,summary, analisis),
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Exportar diagnóstico (PDF)'),
      ),
    );
  }

  Future<void> _verPdf(
      BuildContext context,
      DashboardSummary summary,
      AnalisisCombinado analisis,
      ) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Diagnóstico en PDF')),
          // PdfPreview ya trae su propia barra de acciones con
          // "compartir" e "imprimir" (que en Android/iOS incluye
          // "Guardar como PDF") — el usuario ve el documento primero y
          // decide qué hacer con él, en vez de saltar directo al share
          // sheet del sistema.
          body: PdfPreview(
            build: (format) => _construirPdfBytes(summary, analisis),
            allowPrinting: true,
            allowSharing: true,
            canChangePageFormat: false,
            canChangeOrientation: false,
            pdfFileName: 'diagnostico_moniguard.pdf',
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _construirPdfBytes(
      DashboardSummary summary, AnalisisCombinado analisis) async {
    final doc = pw.Document();

    final colorCacao = PdfColor.fromHex('#3E2723');
    final colorVerde = PdfColor.fromHex('#2E7D32');
    final colorVerdeClaro = PdfColor.fromHex('#81C784');

    PdfColor colorPorVeredicto() {
      switch (analisis.veredicto) {
        case NivelRiesgo.bajo: return PdfColor.fromHex('#2E7D32');
        case NivelRiesgo.medio: return PdfColor.fromHex('#EF6C00');
        case NivelRiesgo.alto: return PdfColor.fromHex('#C62828');
        case NivelRiesgo.desconocido: return PdfColors.grey700;
      }
    }

    final colorVeredicto = colorPorVeredicto();
    final ahora = DateTime.now();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.fromLTRB(36, 28, 36, 24),
              decoration: pw.BoxDecoration(color: colorCacao),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    children: [
                      pw.Text('Moni',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text('Guard',
                          style: pw.TextStyle(
                              color: colorVerdeClaro,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Text('REPORTE DE DIAGNÓSTICO',
                      style: pw.TextStyle(
                          color: PdfColors.white, fontSize: 10, letterSpacing: 1.5)),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(36, 24, 36, 0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(summary.parcela.nombre,
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    children: [
                      pw.Text(summary.parcela.ubicacion,
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year} · ${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: colorVeredicto, width: 1.5),
                      borderRadius: pw.BorderRadius.circular(10),
                      color: PdfColor.fromHex('#FAFAFA'),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('RIESGO DE MONILIASIS',
                            style: pw.TextStyle(
                                fontSize: 11,
                                color: colorVeredicto,
                                letterSpacing: 2,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Text(analisis.veredicto.label.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 34,
                                fontWeight: pw.FontWeight.bold,
                                color: colorVeredicto)),
                        pw.SizedBox(height: 4),
                        pw.Text('Índice de riesgo: ${analisis.porcentaje}%',
                            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 28),
                  pw.Text('FUENTES DEL DIAGNÓSTICO',
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: colorCacao,
                          letterSpacing: 1.2)),
                  pw.SizedBox(height: 10),
                  _filaFuentePdf(
                    colorVerde: colorVerde,
                    titulo: 'Predicción climática (Inteligencia Artificial)',
                    detalle:
                    'Modelo de clasificación supervisada (K-Means + XGBoost), entrenado con clima histórico real de Open-Meteo.',
                    resultado: analisis.fuenteClima.nivel.label,
                    peso: analisis.fuenteClima.peso,
                  ),
                  pw.SizedBox(height: 12),
                  _filaFuentePdf(
                    colorVerde: colorVerde,
                    titulo: 'Observaciones de campo (procesamiento de lenguaje natural)',
                    detalle: analisis.fuenteCampo.bitacorasAnalizadas > 0
                        ? 'Análisis automático del texto de ${analisis.fuenteCampo.bitacorasAnalizadas} bitácora(s) reciente(s), vía modelo BETO (BERT en español).'
                        : 'Sin bitácoras recientes con texto analizado.',
                    resultado: analisis.fuenteCampo.etiquetaPredominante ?? 'Sin datos',
                    peso: analisis.fuenteCampo.peso,
                  ),
                  pw.SizedBox(height: 28),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#E8F5E9'),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('RECOMENDACIÓN TÉCNICA',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: colorVerde,
                                letterSpacing: 1.2)),
                        pw.SizedBox(height: 8),
                        pw.Text(analisis.recomendacion,
                            style: const pw.TextStyle(fontSize: 12, lineSpacing: 3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.Spacer(),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MoniGuard · Detección temprana de moniliasis en cacao',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Universidad Politécnica de Chiapas',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  pw.Widget _filaFuentePdf({
    required PdfColor colorVerde,
    required String titulo,
    required String detalle,
    required String resultado,
    required double peso,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(titulo,
                    style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(detalle,
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(resultado.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold, color: colorVerde)),
                pw.Text('${(peso * 100).round()}% del peso',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BitacorasRecientesSection extends StatefulWidget {
  const _BitacorasRecientesSection();

  @override
  State<_BitacorasRecientesSection> createState() => _BitacorasRecientesSectionState();
}

class _BitacorasRecientesSectionState extends State<_BitacorasRecientesSection> {
  List<Bitacora>? _bitacoras;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    try {
      final repo = getIt<BitacoraRepository>();
      final lista = await repo.listarRemotas();
      if (mounted) {
        setState(() {
          _bitacoras = lista.take(5).toList();
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bitacoras = [];
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_bitacoras == null || _bitacoras!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text('Aún no hay bitácoras registradas.',
            style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }
    return Column(
      children: _bitacoras!.map((b) => Card(
        shape: AppShapes.cardShape,
        child: ListTile(
          leading: Icon(Icons.edit_note_rounded, color: cs.secondary),
          title: Text(b.estadoMazorca?.label ?? 'Sin estado'),
          subtitle: Text(
            b.texto?.isNotEmpty == true ? b.texto! : 'Sin notas adicionales',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${b.creadaEn.day}/${b.creadaEn.month}',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
      )).toList(),
    );
  }
}