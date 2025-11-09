import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyUsername = 'user_username';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<Map<String, String>?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return null;

    return {
      'email': prefs.getString(_keyEmail) ?? '',
      'username': prefs.getString(_keyUsername) ?? '',
    };
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user already exists
    final existingEmail = prefs.getString(_keyEmail);
    if (existingEmail != null && existingEmail.isNotEmpty) {
      return false; // User already registered
    }

    // Save user credentials
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyIsLoggedIn, true);

    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get stored credentials
    final storedEmail = prefs.getString(_keyEmail);
    final storedPassword = prefs.getString(_keyPassword);

    // Check if credentials match
    if (storedEmail == email && storedPassword == password) {
      await prefs.setBool(_keyIsLoggedIn, true);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<bool> hasRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    return email != null && email.isNotEmpty;
  }

  Future<bool> updateProfile({
    required String username,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsername, username);
      await prefs.setString(_keyEmail, email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString(_keyPassword);

    // Verify current password
    if (storedPassword != currentPassword) {
      return false;
    }

    // Update to new password
    await prefs.setString(_keyPassword, newPassword);
    return true;
  }
}
