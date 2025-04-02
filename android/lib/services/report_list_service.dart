import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plastrack/config/constants.dart';
import 'package:plastrack/models/report_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class ReportListService {
  final String _baseUrl = Constants.baseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger('ReportListService');

  Map<String, _CachedData<List<Report>>> _reportsCache = {};

  final Map<String, Completer<List<Report>>> _pendingRequests = {};

  static const Duration _cacheDuration = Duration(minutes: 5);

  String? get userId => _auth.currentUser?.uid;

  Future<List<Report>> getUserReports() async {
    final String? currentUserId = userId;
    if (currentUserId == null) {
      _logger.warning('Attempted to fetch reports while not logged in');
      throw Exception('User not logged in');
    }

    final cacheEntry = _reportsCache[currentUserId];
    if (cacheEntry != null && !cacheEntry.isExpired) {
      _logger.fine('Returning cached reports for user $currentUserId');
      return cacheEntry.data;
    }

    if (_pendingRequests.containsKey(currentUserId)) {
      _logger.fine(
        'Request already in progress for $currentUserId, joining existing request',
      );
      return _pendingRequests[currentUserId]!.future;
    }

    final completer = Completer<List<Report>>();
    _pendingRequests[currentUserId] = completer;

    try {
      final client = http.Client();

      try {
        if (_auth.currentUser?.uid != currentUserId) {
          throw Exception('User changed during request preparation');
        }

        final response = await client
            .post(
              Uri.parse('$_baseUrl/trash/my-reports'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'firebaseId': currentUserId}),
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException('Request timed out after 15 seconds');
              },
            );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonData = json.decode(response.body);

          if (jsonData['success'] == true && jsonData['data'] != null) {
            List<Report> reports = [];

            for (var reportData in jsonData['data']) {
              try {
                if (reportData is! Map<String, dynamic>) {
                  _logger.warning('Skipping invalid report item: $reportData');
                  continue;
                }

                final reportJson = reportData;
                final feedbackText = reportJson['feedback'] as String?;

                String? aiResponseString = reportJson['aiResponse'] as String?;
                Map<String, dynamic>? aiResponseJson;

                if (aiResponseString != null && aiResponseString.isNotEmpty) {
                  try {
                    aiResponseJson = json.decode(aiResponseString);
                  } catch (e) {
                    _logger.warning('Error parsing AI response: $e');
                  }
                }

                reports.add(
                  Report.fromJson(
                    reportJson,
                    feedback: feedbackText,
                    aiResponseJson: aiResponseJson,
                  ),
                );
              } catch (e, stackTrace) {
                _logger.warning('Error parsing report item: $e\n$stackTrace');
              }
            }
            _reportsCache[currentUserId] = _CachedData<List<Report>>(reports);

            completer.complete(reports);
            return reports;
          } else {
            throw Exception(
              'Invalid response format: success=${jsonData['success']}, data=${jsonData['data']}',
            );
          }
        } else {
          throw Exception(
            'Server error: ${response.statusCode}, body: ${response.body}',
          );
        }
      } finally {
        client.close();
      }
    } catch (e, stackTrace) {
      _logger.severe('Error fetching reports: $e\n$stackTrace');
      completer.completeError(
        Exception('Error fetching reports: $e'),
        stackTrace,
      );
      throw Exception('Error fetching reports: $e');
    } finally {
      _pendingRequests.remove(currentUserId);
    }
  }

  void clearCache([String? userId]) {
    if (userId != null) {
      _reportsCache.remove(userId);
      _logger.info('Cache cleared for user $userId');
    } else {
      _reportsCache.clear();
      _logger.info('All cache cleared');
    }
  }

  void handleAppResume() {
    final currentTime = DateTime.now();

    _reportsCache.removeWhere((key, value) => value.isExpired);
    _logger.fine('Cleaned up expired cache entries on app resume');
  }
}

class _CachedData<T> {
  final T data;
  final DateTime timestamp;

  _CachedData(this.data) : timestamp = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(timestamp) > ReportListService._cacheDuration;
}
