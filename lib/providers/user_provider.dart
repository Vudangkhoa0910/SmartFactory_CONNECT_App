import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';

/// Simple user state provider for testing role switching
/// Uses SharedPreferences to persist role across app restarts
class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();
  factory UserProvider() => _instance;
  UserProvider._internal() {
    _loadRole();
  }

  static const String _roleKey = 'user_role_test';
  UserRole _currentRole = UserRole.worker;
  bool _isLoaded = false;

  // Cached user profile data
  Map<String, dynamic>? _cachedProfileData;
  bool _isProfileLoading = false;
  DateTime? _lastProfileFetch;

  UserRole get currentRole => _currentRole;
  bool get isLoaded => _isLoaded;
  Map<String, dynamic>? get cachedProfileData => _cachedProfileData;
  bool get isProfileLoading => _isProfileLoading;

  /// Get cached profile or fetch from API (caches for 5 minutes)
  Future<Map<String, dynamic>?> getProfileData({
    bool forceRefresh = false,
  }) async {
    // Return cached data if available and not expired (5 min cache)
    if (!forceRefresh &&
        _cachedProfileData != null &&
        _lastProfileFetch != null &&
        DateTime.now().difference(_lastProfileFetch!).inMinutes < 5) {
      return _cachedProfileData;
    }

    // Prevent multiple simultaneous fetches
    if (_isProfileLoading) {
      // Wait for current fetch to complete
      while (_isProfileLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedProfileData;
    }

    _isProfileLoading = true;
    notifyListeners();

    try {
      final result = await AuthService().getProfile();
      if (result['success'] == true && result['data'] != null) {
        _cachedProfileData = result['data'];
        _lastProfileFetch = DateTime.now();
      }
    } catch (e) {
      // Keep existing cache on error
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }

    return _cachedProfileData;
  }

  /// Clear cached profile (call on logout)
  void clearProfileCache() {
    _cachedProfileData = null;
    _lastProfileFetch = null;
    notifyListeners();
  }

  Future<void> _loadRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roleString = prefs.getString(_roleKey);

      if (roleString != null) {
        // Convert string back to UserRole
        switch (roleString) {
          case 'worker':
            _currentRole = UserRole.worker;
            break;
          case 'sv':
            _currentRole = UserRole.sv;
            break;
          default:
            _currentRole = UserRole.worker;
        }
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setRole(UserRole role) async {
    _currentRole = role;
    notifyListeners();

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      String roleString = role == UserRole.sv ? 'sv' : 'worker';
      await prefs.setString(_roleKey, roleString);
    } catch (e) {
      // Ignore save errors for now
    }
  }

  /// Set role by string (from API response)
  Future<void> setUserRole(String roleString) async {
    UserRole role;
    switch (roleString.toLowerCase()) {
      case 'leader':
      case 'sv':
      case 'manager':
        role = UserRole.sv;
        break;
      case 'worker':
      case 'user':
      default:
        role = UserRole.worker;
        break;
    }
    await setRole(role);
  }

  bool get isLeader => _currentRole == UserRole.sv;
  bool get isWorker => _currentRole == UserRole.worker;
}
