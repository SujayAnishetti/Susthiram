import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:susthiram/features/scan/domain/garment_analysis.dart';

class GeminiService {
  // TODO: Change this to your Cloud Run URL for production
  // Android Emulator: 10.0.2.2, Physical Device: use your computer's IP
  // Make sure your phone is on the same WiFi network as your computer
  static const String _baseUrl = 'https://susthiram-backend-1076778611890.europe-west1.run.app';

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<GarmentAnalysis> analyzeGarment(
    File frontImage,
    File backImage, {
    String userId = 'default_user',
  }) async {
    final uri = Uri.parse('$_baseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);

    // Get current location
    final position = await _getCurrentLocation();

    // Add form fields
    request.fields['user_id'] = userId;
    if (position != null) {
      request.fields['latitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();
    }

    // Add images as multipart files
    request.files.add(
      await http.MultipartFile.fromPath('front_image', frontImage.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath('back_image', backImage.path),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return GarmentAnalysis.fromJson(jsonMap);
      } else {
        throw Exception(
          'Backend error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to analysis service: $e');
    }
  }
}
