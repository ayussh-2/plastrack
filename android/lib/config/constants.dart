import '../utils/preferences_utils.dart';

class Constants {
  static String baseUrl = PreferencesUtils.DEFAULT_SERVER_URL;
  static String frontendUrl = 'http://localhost:3000';
  static String ogImageEndpoint = '$frontendUrl/api/og-image';
  static Future<void> initializeBaseUrl() async {
    baseUrl = await PreferencesUtils.getServerUrl();
  }
}
