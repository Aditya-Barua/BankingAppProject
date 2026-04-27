import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'security_service.dart';

class AuthService with ChangeNotifier {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SecurityService _securityService = SecurityService();

  User? _user;
  bool _isLoading = false;
  final bool _isMockMode = true;

  AuthService() {
    // For production, uncomment this and initialize Firebase in main.dart
    /*
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    */
  }

  bool get isAuthenticated =>
      _user != null || (_isMockMode && _mockUser != null);
  bool get isLoading => _isLoading;

  String? _mockUser;

  // Mock User object or similar
  dynamic get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(seconds: 1));
        _mockUser = 'mock_uid_123';
      } else {
        // await _firebaseAuth.signInWithEmailAndPassword(...)
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isMockMode) {
      _mockUser = null;
    } else {
      // await _firebaseAuth.signOut();
    }
    notifyListeners();
  }

  Future<bool> authenticateWithBiometrics() async {
    final available = await _securityService.isBiometricAvailable();
    if (available) {
      return await _securityService.authenticate();
    }
    return false;
  }
}
