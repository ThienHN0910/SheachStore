import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api/cloudinary_config.dart';

class CloudinaryService {
  Future<String> uploadImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBytes = await response.stream.toBytes();
    final responseString = utf8.decode(responseBytes);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(responseString) as Map<String, dynamic>;
      final secureUrl = data['secure_url'] as String?;
      if (secureUrl != null) {
        return secureUrl;
      }
      throw Exception('Failed to get secure_url from Cloudinary response.');
    } else {
      try {
        final errorData = jsonDecode(responseString) as Map<String, dynamic>;
        final errorMessage = errorData['error']?['message']?.toString();
        if (errorMessage != null) {
          throw Exception('Cloudinary error: $errorMessage');
        }
      } catch (_) {}
      throw Exception('Cloudinary upload failed: Status code ${response.statusCode}');
    }
  }
}
