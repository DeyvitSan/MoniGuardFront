import 'package:flutter/foundation.dart';

import '../../../home/domain/dashboard_repository.dart';
import '../../../home/domain/entities/dashboard_summary.dart';

enum AnalisisStatus { idle, loading, success, failure }

class AnalisisProvider extends ChangeNotifier {
  final DashboardRepository _repo;

  AnalisisProvider({required DashboardRepository repository})
      : _repo = repository;

  AnalisisStatus _status = AnalisisStatus.idle;
  DashboardSummary? _summary;
  String? _errorMessage;

  AnalisisStatus get status => _status;
  DashboardSummary? get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AnalisisStatus.loading;

  Future<void> cargar() async {
    _status = AnalisisStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _repo.getSummary();
      _status = AnalisisStatus.success;
    } on DashboardException catch (e) {
      _status = AnalisisStatus.failure;
      _errorMessage = e.message;
    } catch (_) {
      _status = AnalisisStatus.failure;
      _errorMessage = 'No se pudo cargar el diagnóstico. Intenta de nuevo.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() => cargar();
}