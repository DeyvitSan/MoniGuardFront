import 'package:flutter/foundation.dart';

import '../../../onboarding/data/repositories/local_storage_service_impl.dart';
import '../../../onboarding/domain/local_storage_service.dart';
import '../../domain/dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

enum DashboardStatus { idle, loading, success, failure }

class HomeProvider extends ChangeNotifier {
  final DashboardRepository _repo;
  final LocalStorageService _storage;

  HomeProvider({required DashboardRepository repository, LocalStorageService? storageService})
      : _repo = repository,
        _storage = storageService ?? LocalStorageServiceImpl();

  int _tabIndex = 0;
  DashboardStatus _status = DashboardStatus.idle;
  String? _errorMessage;
  DashboardSummary? _summary;
  String? _nombreUsuario;

  int get tabIndex => _tabIndex;
  DashboardStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DashboardSummary? get summary => _summary;
  String? get nombreUsuario => _nombreUsuario;
  bool get isLoading => _status == DashboardStatus.loading;

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> loadSummary() async {
    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Nombre cacheado localmente (ya lo trajo el login/perfil) — se lee
    // aparte y no bloquea el dashboard si tarda o falla.
    _storage.getUserName().then((value) {
      if (value != null && value.trim().isNotEmpty) {
        _nombreUsuario = value.trim();
        notifyListeners();
      }
    });

    try {
      _summary = await _repo.getSummary();
      _status = DashboardStatus.success;
    } on DashboardException catch (e) {
      _status = DashboardStatus.failure;
      _errorMessage = e.message;
    } catch (_) {
      _status = DashboardStatus.failure;
      _errorMessage = 'Error inesperado al cargar el dashboard';
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() => loadSummary();
}