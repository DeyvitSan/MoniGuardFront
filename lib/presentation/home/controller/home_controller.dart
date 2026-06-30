// Maneja dos responsabilidades mínimas del Home:
//   1. Índice activo del BottomNavigationBar
//   2. Carga y estado de los datos del dashboard

import 'package:flutter/foundation.dart';

import '../../../domain/interfaces/i_dashboard_repository.dart';
import '../../../domain/models/dashboard_summary.dart';

enum DashboardStatus { idle, loading, success, failure }

class HomeController extends ChangeNotifier {
  final IDashboardRepository _repo;

  HomeController({required IDashboardRepository repository})
      : _repo = repository;

  //Estado
  int               _tabIndex  = 0;
  DashboardStatus   _status    = DashboardStatus.idle;
  String?           _errorMessage;
  DashboardSummary? _summary;

  //Getters
  int               get tabIndex     => _tabIndex;
  DashboardStatus   get status       => _status;
  String?           get errorMessage => _errorMessage;
  DashboardSummary? get summary      => _summary;
  bool              get isLoading    => _status == DashboardStatus.loading;

  //Tab navigation
  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

  //Carga de datos
  // accessToken: en la siguiente iteración lo sacamos de flutter_secure_storage.
  // Por ahora se pasa desde la pantalla (viene del AuthResponse del login).
  Future<void> loadSummary({String accessToken = ''}) async {
    _status       = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _repo.getSummary(accessToken: accessToken);
      _status  = DashboardStatus.success;
    } on DashboardException catch (e) {
      _status       = DashboardStatus.failure;
      _errorMessage = e.message;
    } catch (_) {
      _status       = DashboardStatus.failure;
      _errorMessage = 'Error inesperado al cargar el dashboard';
    } finally {
      notifyListeners();
    }
  }

  // Refresh
  Future<void> refresh({String accessToken = ''}) =>
      loadSummary(accessToken: accessToken);
}