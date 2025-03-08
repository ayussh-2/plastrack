import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2ways/config/constants.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    this.data,
    this.error,
    required this.statusCode,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class ApiClient {
  final String baseUrl = Constants.baseUrl;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ApiClient({baseUrl});

  // Helper method to get authentication token
  Future<String?> _getAuthToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Helper to build headers with authentication
  Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final token = await _getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParams,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(additionalHeaders: headers),
      );

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: await _getHeaders(additionalHeaders: headers),
        body: body != null ? json.encode(body) : null,
      );

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: await _getHeaders(additionalHeaders: headers),
        body: body != null ? json.encode(body) : null,
      );

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.Request('DELETE', uri);

      request.headers.addAll(await _getHeaders(additionalHeaders: headers));

      if (body != null) {
        request.body = json.encode(body);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // Helper method to process responses
  ApiResponse<T> _processResponse<T>(
      http.Response response,
      T Function(dynamic)? fromJson,
      ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse<T>(statusCode: response.statusCode);
      }

      final dynamic jsonData = json.decode(response.body);

      if (fromJson != null) {
        final T data = fromJson(jsonData);
        return ApiResponse<T>(
          data: data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<T>(
        data: jsonData as T,
        statusCode: response.statusCode,
      );
    } else {
      String errorMessage;
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'Unknown error occurred';
      } catch (_) {
        errorMessage = response.body;
      }

      return ApiResponse<T>(
        error: errorMessage,
        statusCode: response.statusCode,
      );
    }
  }
}