import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user profile from Firestore
  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        _userProfile = UserModel.fromMap(doc.data()!, doc.id);
      } else {
        _error = 'User profile not found in database';
      }
    } on FirebaseException catch (e) {
      _error = _handleFirebaseError(e);
    } catch (e) {
      _error = 'An unexpected error occurred while loading profile';
      debugPrint('Load Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update full name in Firestore
  Future<bool> updateFullName(String newName) async {
    final user = _auth.currentUser;
    if (user == null || _userProfile == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': newName,
      });

      // Update local state
      _userProfile = UserModel(
        id: _userProfile!.id,
        email: _userProfile!.email,
        fullName: newName,
        balance: _userProfile!.balance,
        accountNumber: _userProfile!.accountNumber,
        createdAt: _userProfile!.createdAt,
      );
      return true;
    } on FirebaseException catch (e) {
      _error = _handleFirebaseError(e);
      return false;
    } catch (e) {
      _error = 'Failed to update profile. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear state on logout
  void clearProfile() {
    _userProfile = null;
    _error = null;
    notifyListeners();
  }

  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to access this data.';
      case 'unavailable':
        return 'Database service is currently unavailable.';
      case 'not-found':
        return 'Requested profile was not found.';
      default:
        return e.message ?? 'A database error occurred.';
    }
  }
}
