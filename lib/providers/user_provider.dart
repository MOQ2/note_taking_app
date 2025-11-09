import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _profilePicUrl;
  bool _isAuthenticated = false;

  // Getters
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get profilePicUrl => _profilePicUrl;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasUser => _userId != null && _userId!.isNotEmpty;

  // Set user data
  Future<void> setUser({
    required String userId,
    required String userName,
    required String userEmail,
    String? profilePicUrl,
  }) async {
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _profilePicUrl = profilePicUrl;
    _isAuthenticated = true;
    await _saveToPreferences();
    notifyListeners();
  }

  // Update user name
  Future<void> updateUserName(String newName) async {
    _userName = newName;
    await _saveToPreferences();
    notifyListeners();
  }

  // Update user email
  Future<void> updateUserEmail(String newEmail) async {
    _userEmail = newEmail;
    await _saveToPreferences();
    notifyListeners();
  }

  // Update profile picture URL
  Future<void> updateProfilePicUrl(String? newUrl) async {
    _profilePicUrl = newUrl;
    await _saveToPreferences();
    notifyListeners();
  }

  // Clear user data
  Future<void> clearUser() async {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _profilePicUrl = null;
    _isAuthenticated = false;
    await _saveToPreferences();
    notifyListeners();
  }

  // Save user to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_userId != null) {
        await prefs.setString('userId', _userId!);
        await prefs.setString('userName', _userName ?? '');
        await prefs.setString('userEmail', _userEmail ?? '');
        await prefs.setString('profilePicUrl', _profilePicUrl ?? '');
        await prefs.setBool('isAuthenticated', _isAuthenticated);
      } else {
        await prefs.remove('userId');
        await prefs.remove('userName');
        await prefs.remove('userEmail');
        await prefs.remove('profilePicUrl');
        await prefs.remove('isAuthenticated');
      }
    } catch (e) {
      debugPrint('Error saving to SharedPreferences: $e');
    }
  }

  // Load user from SharedPreferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      _profilePicUrl = prefs.getString('profilePicUrl');
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from SharedPreferences: $e');
    }
  }
}
