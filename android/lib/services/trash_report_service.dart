import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:waste2ways/utils/api_client.dart';
import 'package:waste2ways/models/trash_report_model.dart';

class TrashReportService {
  TrashReportModel? _trashReport;
  TrashReportModel? get trashReport => _trashReport;

  final ApiClient _apiClient = ApiClient(enableLogging: true);

  final String _cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? ''}/upload';
  final String _cloudinaryPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    developer.log('Uploading image to Cloudinary', name: 'TrashReportService');
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
      // final imageUrl = await _uploadImageToCloudinary(image);
      final imageUrl =
          "https://res.cloudinary.com/dmvdbpyqk/image/upload/v1742136422/esh6dwk5pktq8fpysmyj.jpg";

      // developer.log('imageUrl: $imageUrl', name: 'TrashReportService');

      final response = await _apiClient.post(
        '/trash/generate',
        body: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'severity': severity,
          'image': imageUrl,
          'firebaseId': userId,
        },
        fromJson: (json) => TrashReportModel.fromJson(json),
      );
      _trashReport = response.data;
      // _trashModel = TrashReportModel(
      //   id: _trashReport!.id,
      //   latitude: latitude.toString(),
      //   longitude: longitude.toString(),
      //   trashType: _trashReport!.trashType,
      //   severity: severity,
      //   image: imageUrl,
      //   timestamp: _trashReport!.timestamp,
      //   userId: userId,
      //   aiResponse: _trashReport!.aiResponse,
      // );

      developer.log(
        'Trash report submitted: ${_trashReport!.toJson()}',
        name: 'TrashReportService',
      );
      return _trashReport!;
    } catch (e) {
      throw Exception('Error submitting report: $e');
    }
  }
}
