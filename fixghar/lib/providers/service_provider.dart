import 'package:flutter/foundation.dart';
import '../models/provider_model.dart';
import '../models/service_model.dart';
import '../services/firestore_service.dart';

/// Manages service listing and provider listing state
class ServiceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<ServiceModel> _services = [];
  List<ProviderModel> _providers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Returns providers filtered by the current search query
  List<ProviderModel> get providers {
    if (_searchQuery.isEmpty) return _providers;
    final q = _searchQuery.toLowerCase();
    return _providers
        .where((p) =>
            p.fullName.toLowerCase().contains(q) ||
            p.area.toLowerCase().contains(q) ||
            p.skills.any((s) => s.toLowerCase().contains(q)))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Services
  // ---------------------------------------------------------------------------

  /// Fetches all available services from Firestore
  Future<void> fetchAllServices() async {
    try {
      _setLoading(true);
      _services = await _firestoreService.getAllServices();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Providers
  // ---------------------------------------------------------------------------

  /// Fetches all providers for the given service category
  Future<void> fetchProvidersByCategory(String category) async {
    try {
      _setLoading(true);
      _providers = await _firestoreService.getProvidersByCategory(category);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Clears the provider list (call when leaving the service listing screen)
  void clearProviders() {
    _providers = [];
    _searchQuery = '';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
