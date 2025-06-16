import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefs {
  static const String USER_DATA_KEY = 'user_data';

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("Saving user data: $userData"); // Debug print
      await prefs.setString(USER_DATA_KEY, json.encode(userData));
    } catch (e) {
      print("Error saving user data: $e");
      throw e;
    }
  }

  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userDataString = prefs.getString(USER_DATA_KEY);
      if (userDataString != null) {
        final userData = json.decode(userDataString) as Map<String, dynamic>;
        print("Retrieved user data: $userData"); // Debug print
        return userData;
      }
      return {};
    } catch (e) {
      print("Error getting user data: $e");
      return {};
    }
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_DATA_KEY);
  }

  static Future<bool> verifyUserData() async {
    try {
      final userData = await getUserData();
      final requiredFields = ['id', 'name', 'email', 'user_type'];

      for (final field in requiredFields) {
        if (!userData.containsKey(field) ||
            userData[field] == null ||
            userData[field].toString().isEmpty) {
          print('Missing or empty required field: $field');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error verifying user data: $e');
      return false;
    }
  }
}
