import 'package:flutter/foundation.dart';

import '../../domain/dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

enum DashboardStatus { idle, loading, success, failure }

class HomeProvider extends ChangeNotifier {
  final DashboardRepository _repo;

  HomeProvider({required DashboardRepository repository})
      : _repo = repository;

  int _tabIndex = 0;
  DashboardStatus _status = DashboardStatus.idle;
  String? _errorMessage;
  DashboardSummary? _summary;

  int get tabIndex => _tabIndex;

  DashboardStatus get status => _status;

  String? get errorMessage => _errorMessage;

  DashboardSummary? get summary => _summary;

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