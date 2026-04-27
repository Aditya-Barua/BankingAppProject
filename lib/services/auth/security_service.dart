import 'package:local_auth/local_auth.dart';

class SecurityService {
  // final LocalAuthentication _auth = LocalAuthentication();
  final bool _isMockMode = true;

  Future<bool> isBiometricAvailable() async {
    if (_isMockMode) return true;
    // final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    // final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    // return canAuthenticate;
    return false;
  }

  Future<bool> authenticate() async {
    if (_isMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    try {
      /*
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your bank account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      */
      return false;
    } catch (e) {
      return false;
    }
  }
}
