import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtils {
  static const String SERVER_URL_KEY = 'server_url';
  static const String DEFAULT_SERVER_URL = 'http://192.168.0.103:4000/api';

  static Future<String> getServerUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SERVER_URL_KEY) ?? DEFAULT_SERVER_URL;
  }

  static Future<bool> setServerUrl(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(SERVER_URL_KEY, url);
  }
}
