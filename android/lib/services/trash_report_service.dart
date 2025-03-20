import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste2ways/config/constants.dart';
import 'dart:developer' as developer;
import 'package:waste2ways/models/trash_report_model.dart';

class TrashReportService {
  TrashReportModel? _trashReport;
  TrashReportModel? get trashReport => _trashReport;

  final String _baseUrl = Constants.baseUrl;
  final String _cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? ''}/upload';
  final String _cloudinaryPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    final uri = Uri.parse(_cloudinaryUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _cloudinaryPreset;

    final fileExtension = imageFile.path.split('.').last;
    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', fileExtension),
    );

    request.files.add(file);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonData = json.decode(responseString);
      return jsonData['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  Future<TrashReportModel> submitTrashReport({
    required double latitude,
    required double longitude,
    required int severity,
    required File image,
    required String userId,
  }) async {
    try {
      final imageUrl = await _uploadImageToCloudinary(image);
      // final imageUrl =
      //     "https://res.cloudinary.com/dmvdbpyqk/image/upload/v1742136422/esh6dwk5pktq8fpysmyj.jpg";

      final Map<String, String> requestBody = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'severity': severity.toString(),
        'image': imageUrl,
        'firebaseId': userId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/trash/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey('data')) {
          _trashReport = TrashReportModel.fromJson(jsonData['data']);

          return _trashReport!;
        } else {
          throw Exception('Invalid response format: missing data field');
        }
      } else {
        throw Exception(
          'Server error: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      developer.log(
        'Error submitting trash report: $e',
        name: 'TrashReportService',
        error: e,
      );
      throw Exception('Error submitting report: $e');
    }
  }

  Future<Map<String, dynamic>> submitFeedback(
    int reportId,
    String feedback,
  ) async {
    try {
      developer.log(
        'Submitting feedback for report ID: $reportId',
        name: 'TrashReportService',
      );
      developer.log('Feedback content: $feedback', name: 'TrashReportService');

      final response = await http.post(
        Uri.parse('$_baseUrl/trash/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'reportId': reportId, 'feedback': feedback}),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData['data'] != null &&
            (jsonData['data']['isInvalid'] == true ||
                jsonData['data']['isInValid'] == true)) {
          String errorMessage =
              'We have detected that your feedback was irrelevant.';
          if (jsonData['data']['message'] != null) {
            errorMessage += ' ' + jsonData['data']['message'];
          }

          return {
            'success': false,
            'message': "It seems like your feedback was irrelevant",
          };
        }

        return {
          'success': true,
          'message':
              jsonData['data']?['message'] ?? 'Feedback successfully submitted',
          'data': jsonData['data'],
        };
      } else {
        developer.log(
          'Server error: ${response.statusCode}',
          name: 'TrashReportService',
        );
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Failed to submit feedback',
        };
      }
    } catch (e) {
      developer.log(
        'Error submitting feedback: $e',
        name: 'TrashReportService',
        error: e,
      );
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
