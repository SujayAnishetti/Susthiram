import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:susthiram/features/chat/presentation/screens/chat_screen.dart';

class AgentOrchestrator {
  // URL of the deployed backend (replace with your Cloud Run URL or localhost for emulator)
  // For Android Emulator use 10.0.2.2, for physical device use your computer's IP
  // Make sure your phone is on the same WiFi network as your computer
  static const String _baseUrl = 'https://susthiram-backend-1076778611890.europe-west1.run.app';

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<ChatMessage> processUserMessage(
    String message,
    String currentAgentType, {
    String userId = 'default_user',
    Map<String, dynamic>? garmentContext,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'message': message,
        'agent_type': currentAgentType,
        'user_id': userId,
      };

      // Add location for Stylist or Vendor agent
      if (currentAgentType == 'Stylist' || currentAgentType == 'Vendor') {
        final position = await _getCurrentLocation();
        if (position != null) {
          body['location'] = {
            'latitude': position.latitude,
            'longitude': position.longitude,
          };
        }
      }

      // Add garment context if provided (for Vendor agent)
      if (garmentContext != null) {
        body['garment_context'] = garmentContext;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatMessage(
          text: data['text'],
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        return ChatMessage(
          text: "Error connecting to agent: ${response.statusCode}",
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      // Fallback to local simulation if backend is not reachable
      print('Backend error: $e. Falling back to local simulation.');
      return _localSimulation(message, currentAgentType);
    }
  }

  ChatMessage _localSimulation(String message, String currentAgentType) {
    if (currentAgentType == 'Stylist') {
      return _handleStylistAgent(message);
    } else if (currentAgentType == 'Vendor') {
      return _handleVendorAgent(message);
    } else {
      return ChatMessage(
        text: "I'm not sure how to help with that yet.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  ChatMessage _handleStylistAgent(String message) {
    if (message.toLowerCase().contains('party')) {
      return ChatMessage(
        text:
            "For a party, I suggest pairing your item with a sleek black blazer and silver accessories. It's a sustainable chic look!",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
    return ChatMessage(
      text:
          "That's a great choice! I can suggest some eco-friendly brands that match this style.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  ChatMessage _handleVendorAgent(String message) {
    if (message.toLowerCase().contains('price')) {
      return ChatMessage(
        text:
            "I've found 3 vendors interested in your material. The highest offer is 500 credits. Shall I accept?",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
    return ChatMessage(
      text:
          "I'm negotiating with local recyclers to get you the best value for your recyclable garments.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
