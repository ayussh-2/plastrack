import '../utils/preferences_utils.dart';

class Constants {
  static String baseUrl = PreferencesUtils.DEFAULT_SERVER_URL;
  static String frontendUrl = 'http://192.168.0.100:3000';
  static String ogImageEndpoint = '$frontendUrl/api/og-image';
  static Future<void> initializeBaseUrl() async {
    baseUrl = await PreferencesUtils.getServerUrl();
  }
}
