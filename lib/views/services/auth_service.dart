import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:dashboard_screen/utility/app_constants.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';
  static const String _legacyTokenKey = 'token';
  static const String _sessionCookieKey = 'session_cookie';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConstants.googleServerClientId,
    scopes: const ['email', 'profile'],
  );

  String _extractCookie(String? rawCookie) {
    if (rawCookie == null || rawCookie.trim().isEmpty) return '';

    final parts = rawCookie.split(',');
    final cookiePairs = <String>[];

    for (final part in parts) {
      final first = part.split(';').first.trim();
      if (first.startsWith('sessionid=') || first.startsWith('csrftoken=')) {
        cookiePairs.add(first);
      }
    }

    return cookiePairs.join('; ');
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String location,
    required String farmType,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.registerApi),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'full_name': fullName.trim(),
              'email': email.trim().toLowerCase(),
              'phone': phone.trim(),
              'location': location.trim(),
              'farm_type': farmType.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(AppConstants.requestTimeout);

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('Register Error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.loginApi),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password.trim(),
            }),
          )
          .timeout(AppConstants.requestTimeout);

      if (response.statusCode != 200) return false;

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] != true) return false;

      final cookie = _extractCookie(response.headers['set-cookie']);
      if (cookie.isNotEmpty) {
        await storage.write(key: _sessionCookieKey, value: cookie);
      }

      final access = data['access']?.toString() ?? data['token']?.toString() ?? '';
      final refresh = data['refresh']?.toString() ?? '';

      if (access.isNotEmpty) {
        await storage.write(key: _accessKey, value: access);
        await storage.write(key: _legacyTokenKey, value: access);
      } else {
        // Live Django backend is session based; keep a small marker so isLoggedIn works.
        await storage.write(key: _accessKey, value: 'session');
        await storage.write(key: _legacyTokenKey, value: 'session');
      }

      await storage.write(key: _refreshKey, value: refresh);
      await storage.write(key: _userKey, value: jsonEncode(data['user'] ?? {}));

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Login Error: $e');
      return false;
    }
  }

  /// Signs the user in with Google, sends the Google ID token to the
  /// backend for verification, and stores the session the same way
  /// normal email/password login() does.
  ///
  /// Returns null on success, or an error message string on failure
  /// (so the UI can show a specific SnackBar instead of a generic one).
  Future<String?> loginWithGoogle() async {
    try {
      // Clear any stale Google session first so the account picker
      // always shows up (helps a lot during testing).
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the picker.
        return 'cancelled';
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        return 'Google se ID token nahi mila. googleServerClientId check karein.';
      }

      final response = await http
          .post(
            Uri.parse(AppConstants.googleLoginApi),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(AppConstants.requestTimeout);

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || data['success'] != true) {
        return data['message']?.toString() ?? 'Google sign-in failed.';
      }

      final cookie = _extractCookie(response.headers['set-cookie']);
      if (cookie.isNotEmpty) {
        await storage.write(key: _sessionCookieKey, value: cookie);
      }

      await storage.write(key: _accessKey, value: 'session');
      await storage.write(key: _legacyTokenKey, value: 'session');
      await storage.write(key: _userKey, value: jsonEncode(data['user'] ?? {}));

      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Google Login Error: $e');
      return 'Network error. Try again.';
    }
  }

  Future<String?> getAccessToken() async => storage.read(key: _accessKey);

  Future<String?> getRefreshToken() async => storage.read(key: _refreshKey);

  Future<String?> getSessionCookie() async => storage.read(key: _sessionCookieKey);

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final raw = await storage.read(key: _userKey);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getCurrentRole() async {
    final user = await getCurrentUser();
    return user?['role']?.toString();
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final cookie = await getSessionCookie();
    return (token != null && token.isNotEmpty) || (cookie != null && cookie.isNotEmpty);
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await storage.delete(key: _userKey);
    await storage.delete(key: _accessKey);
    await storage.delete(key: _refreshKey);
    await storage.delete(key: _legacyTokenKey);
    await storage.delete(key: _sessionCookieKey);
  }
}
