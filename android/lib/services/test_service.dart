import 'package:plastrack/utils/api_client.dart';

class TestService {
  final ApiClient _apiClient = ApiClient(enableLogging: true);

  Future<ApiResponse> getTest() async {
    final response = await _apiClient.get("/", fromJson: (json) => json);

    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
    if (response.error != null) {
      print('Response error: ${response.error}');
    }

    return response;
  }
}
