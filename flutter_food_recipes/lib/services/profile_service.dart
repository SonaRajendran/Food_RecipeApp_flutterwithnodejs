import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class ProfileService {
  static const String _profileImageKey = "profile_image_url";
  static const String _profileNameKey = "profile_name";
  static const String _profileEmailKey = "profile_email";
  static const String _baseUrl =
      "http://localhost:3000"; // Use 10.0.2.2:3000 for emulator

  static MediaType _getMediaType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  static Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      final uri = Uri.parse("$_baseUrl/api/profile/upload");
      final request = http.MultipartRequest('POST', uri);
      final contentType = _getMediaType(imageFile.name);

      if (kIsWeb) {
        Uint8List bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'profileImage',
            bytes,
            filename: imageFile.name,
            contentType: contentType,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            imageFile.path,
            filename: imageFile.name,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['imageUrl'];
        await _saveProfileImageUrl(imageUrl);
        return imageUrl;
      } else {
        throw Exception(
          "Failed to upload image. Status code: ${response.statusCode} Error: ${response.body}",
        );
      }
    } catch (e) {
      print("Error during image upload: $e");
      return null;
    }
  }

  static Future<Map<String, String>?> getProfile() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/api/profile"));
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_profileNameKey, user['name']);
        await prefs.setString(_profileEmailKey, user['email']);
        await prefs.setString(
          _profileImageKey,
          user['profile_image_url'] ?? '',
        );
        return {
          'name': user['name'],
          'email': user['email'],
          'profile_image_url': user['profile_image_url'] ?? '',
        };
      } else {
        throw Exception("Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching profile: $e");
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString(_profileNameKey) ?? 'John Doe',
        'email': prefs.getString(_profileEmailKey) ?? 'johndoe@example.com',
        'profile_image_url': prefs.getString(_profileImageKey) ?? '',
      };
    }
  }

  static Future<bool> updateProfile(String name, String email) async {
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/api/profile"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email}),
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_profileNameKey, name);
        await prefs.setString(_profileEmailKey, email);
        return true;
      } else {
        throw Exception("Failed to update profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

  static Future<String?> getProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  static Future<void> _saveProfileImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, url);
  }
}
