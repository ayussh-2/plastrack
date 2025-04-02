import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'package:plastrack/config/constants.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({this.data, this.error, required this.statusCode});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class ApiClient {
  final String baseUrl = Constants.baseUrl;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final bool enableLogging;

  ApiClient({String? baseUrl, this.enableLogging = true});

  Future<String?> _getAuthToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  Future<Map<String, String>> _getHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    final token = await _getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  void _logRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    dynamic body,
  ) {
    if (!enableLogging) return;

    // developer.log('API Request: $method ${uri.toString()}', name: 'ApiClient');
    // developer.log('Headers: ${headers.toString()}', name: 'ApiClient');
    if (body != null) {
      developer.log(
        'Body: ${body is String ? body : json.encode(body)}',
        name: 'ApiClient',
      );
    }
  }

  void _logResponse(http.Response response) {
    if (!enableLogging) return;
    developer.log('Response Headers: ${response.headers}', name: 'ApiClient');

    try {
      final dynamic jsonData = json.decode(response.body);
      developer.log('Response Body: $jsonData', name: 'ApiClient');
    } catch (e) {
      developer.log('Response parsing error: $e', name: 'ApiClient');
      developer.log('Raw response body: ${response.body}', name: 'ApiClient');
    }
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final requestHeaders = await _getHeaders(additionalHeaders: headers);

      // _logRequest('GET', uri, requestHeaders, null);

      final response = await http.get(uri, headers: requestHeaders);
      // _logResponse(response);
      final resp = _processResponse<T>(response, fromJson);
      return resp;
    } catch (e) {
      developer.log('API Error: ${e.toString()}', name: 'ApiClient', error: e);
      return ApiResponse(error: e.toString(), statusCode: 500);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _getHeaders(additionalHeaders: headers);
      final jsonBody = body != null ? json.encode(body) : null;

      _logRequest('POST', uri, requestHeaders, jsonBody);

      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: jsonBody,
      );

      // _logResponse(response);
      return _processResponse<T>(response, fromJson);
    } catch (e) {
      developer.log('API Error: ${e.toString()}', name: 'ApiClient', error: e);
      return ApiResponse(error: e.toString(), statusCode: 500);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _getHeaders(additionalHeaders: headers);
      final jsonBody = body != null ? json.encode(body) : null;

      _logRequest('PUT', uri, requestHeaders, jsonBody);

      final response = await http.put(
        uri,
        headers: requestHeaders,
        body: jsonBody,
      );

      _logResponse(response);
      return _processResponse<T>(response, fromJson);
    } catch (e) {
      developer.log('API Error: ${e.toString()}', name: 'ApiClient', error: e);
      return ApiResponse(error: e.toString(), statusCode: 500);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _getHeaders(additionalHeaders: headers);
      final jsonBody = body != null ? json.encode(body) : null;

      _logRequest('DELETE', uri, requestHeaders, jsonBody);

      final request = http.Request('DELETE', uri);
      request.headers.addAll(requestHeaders);

      if (body != null) {
        request.body = jsonBody!;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);
      return _processResponse<T>(response, fromJson);
    } catch (e) {
      developer.log('API Error: ${e.toString()}', name: 'ApiClient', error: e);
      return ApiResponse(error: e.toString(), statusCode: 500);
    }
  }

  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResponse<T>(statusCode: response.statusCode);
        }

        final dynamic jsonData = json.decode(response.body);

        if (fromJson != null) {
          try {
            final dynamic dataToConvert =
                jsonData is Map<String, dynamic> && jsonData.containsKey('data')
                    ? jsonData['data']
                    : jsonData;

            final T data = fromJson(dataToConvert);
            return ApiResponse<T>(data: data, statusCode: response.statusCode);
          } catch (e) {
            developer.log(
              '[Parse error] Failed to convert with fromJson: ${e.toString()}',
              name: 'ApiClient',
              error: e,
            );
            return ApiResponse<T>(
              statusCode: response.statusCode,
              error: 'Failed to parse response: ${e.toString()}',
            );
          }
        }

        if (jsonData is T) {
          return ApiResponse<T>(
            data: jsonData,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<T>(
            statusCode: response.statusCode,
            error: 'Response type mismatch',
          );
        }
      } else {
        developer.log("[Line 240] Error response received", name: "ApiClient");
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          developer.log('[Line 243] Error data: $errorData', name: "ApiClient");
          errorMessage =
              errorData['message']?.toString() ??
              (errorData['error']?.toString() ?? 'Unknown error occurred');
          developer.log(
            '[Line 247] Error message: $errorMessage',
            name: "ApiClient",
          );
        } catch (_) {
          errorMessage =
              response.body.isNotEmpty
                  ? response.body
                  : 'Request failed with status: ${response.statusCode}';
          developer.log(
            "[Line 253] Error message from body: $errorMessage",
            name: "ApiClient",
          );
        }

        developer.log("[Line 259] Returning error response", name: "ApiClient");

        return ApiResponse<T>(
          error: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      developer.log(
        '[Line 267] Process response error: ${e.toString()}',
        name: 'ApiClient',
        error: e,
      );
      return ApiResponse<T>(
        error: 'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }
}
