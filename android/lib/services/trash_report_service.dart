import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:waste2ways/utils/api_client.dart';
import 'package:waste2ways/models/trash_report_model.dart';

class TrashReportService {
  final ApiClient _apiClient = ApiClient(enableLogging: true);

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
      developer.log('imageUrl: $imageUrl', name: 'TrashReportService');

      final response = await _apiClient.post(
        '/trash/generate',
        body: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'severity': severity.toString(),
          'image': imageUrl,
          'userId': userId,
        },
        fromJson: (json) => json,
      );

      if (response.data != null) {
        developer.log('Trash report submitted', name: 'TrashReportService');
        developer.log(
          'Response JSON: ${json.encode(response.data['data'])}',
          name: 'TrashReportService',
        );

        final trashReport = TrashReportModel.fromJson(response.data['data']);
        developer.log(
          'Parsed TrashReport: ${json.encode(trashReport.toJson())}',
          name: 'TrashReportService',
        );

        return trashReport;
      } else {
        developer.log(
          'Error submitting trash report: ${response.error}',
          name: 'TrashReportService',
        );
        throw Exception('Failed to submit trash report');
      }
    } catch (e) {
      throw Exception('Error submitting report: $e');
    }
  }
}
