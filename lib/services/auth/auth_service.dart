import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'security_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SecurityService _securityService = SecurityService();

  User? _user;
  bool _isLoading = false;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  User? get user => _user;

  // Login implementation
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registration implementation
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Create user in Firebase Auth
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // 2. Generate random demo account number
        String accountNumber = _generateAccountNumber();

        // 3. Create user profile in Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'fullName': fullName,
          'email': email,
          'accountNumber': accountNumber,
          'balance': 1000.0, // Starting bonus balance
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      debugPrint(
        'FirebaseException during registration: ${e.code} - ${e.message}',
      );
      throw 'Firebase Error (${e.code}): ${e.message ?? 'Unknown error'}';
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      throw 'Registration failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout implementation
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }

  // Biometric login
  Future<bool> authenticateWithBiometrics() async {
    final available = await _securityService.isBiometricAvailable();
    if (available) {
      return await _securityService.authenticate();
    }
    return false;
  }

  // Helper: Generate random 10-digit account number
  String _generateAccountNumber() {
    final random = Random();
    String number = '';
    for (int i = 0; i < 10; i++) {
      number += random.nextInt(10).toString();
    }
    return number;
  }

  // Helper: Convert Firebase errors to user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your internet.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
