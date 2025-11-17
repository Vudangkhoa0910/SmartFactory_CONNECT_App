import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

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

  UserRole get currentRole => _currentRole;
  bool get isLoaded => _isLoaded;

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

  bool get isLeader => _currentRole == UserRole.sv;
  bool get isWorker => _currentRole == UserRole.worker;
}
