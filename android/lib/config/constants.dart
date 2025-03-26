import '../utils/preferences_utils.dart';

class Constants {
  static String baseUrl = PreferencesUtils.DEFAULT_SERVER_URL;

  static Future<void> initializeBaseUrl() async {
    baseUrl = await PreferencesUtils.getServerUrl();
  }
}
