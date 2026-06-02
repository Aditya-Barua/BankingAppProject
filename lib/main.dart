import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'services/auth/auth_service.dart';
import 'core/providers/bank_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // For Web, you MUST provide your Firebase configuration here
      // You can find this in your Firebase Console -> Project Settings -> General -> Your Apps -> Web App
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDivUAhmEFN0zDKk20WOeoQaGIlepHTvww",
          appId: "1:733344360667:web:4940c97b66f046c774c4fe",
          messagingSenderId: "733344360667",
          projectId: "banking-app-b193e",
          storageBucket: "banking-app-b193e.firebasestorage.app",
          authDomain: "banking-app-b193e.firebaseapp.com",
        ),
      );
    } else {
      // On Mobile (Android/iOS), it reads from google-services.json or GoogleService-Info.plist
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BankProvider()),
      ],
      child: const BankApp(),
    ),
  );
}

class BankApp extends StatelessWidget {
  const BankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Check authentication status
    if (authService.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
