import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtils {
  static const String SERVER_URL_KEY = 'server_url';
  static const String DEFAULT_SERVER_URL = 'http://192.168.0.100:4000/api';

  static const String FRONTEND_URL_KEY = 'frontend_url';
  static const String DEFAULT_FRONTEND_URL = 'http://192.168.0.100:3000';

  static Future<String> getServerUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SERVER_URL_KEY) ?? DEFAULT_SERVER_URL;
  }

  static Future<bool> setServerUrl(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(SERVER_URL_KEY, url);
  }

  static Future<String> getFrontendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(FRONTEND_URL_KEY) ?? DEFAULT_FRONTEND_URL;
  }

  static Future<void> setFrontendUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FRONTEND_URL_KEY, url);
  }
}
