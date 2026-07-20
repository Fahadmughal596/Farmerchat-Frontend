import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // Theme Colors
  // ---------------------------------------------------------------------------
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color secondaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFE9F5EE);
  static const Color bgCream = Color(0xFFFBF7EE);
  static const Color goldenText = Color(0xFFC7A16F);
  static const Color dangerRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);

  // ---------------------------------------------------------------------------
  // Backend Configuration
  // ---------------------------------------------------------------------------
  static const String baseUrl = 'https://farmerchat.talkify.app';

  // ---------------------------------------------------------------------------
  // Auth APIs
  // ---------------------------------------------------------------------------
  static const String registerApi = '$baseUrl/api/register/';
  static const String loginApi = '$baseUrl/api/login/';
  static const String profileApi = '$baseUrl/api/profile/';
  static const String googleLoginApi = '$baseUrl/api/auth/google/';

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // This MUST be the "Web application" OAuth Client ID from Google Cloud
  // Console (NOT the Android one). It has to match GOOGLE_CLIENT_ID in the
  // backend's .env file, otherwise token verification will fail.
  // ---------------------------------------------------------------------------
  static const String googleServerClientId =
      '550186666113-i3aap0q9ss9o2q9duod7dtsom5p4ssha.apps.googleusercontent.com';

  // ---------------------------------------------------------------------------
  // Public / Mobile APIs
  // ---------------------------------------------------------------------------
  static const String marketRatesApi = '$baseUrl/api/market-rates/';
  static const String schemesApi = '$baseUrl/api/schemes/';
  static const String chatbotApi = '$baseUrl/api/chatbot/';
  static const String diseasePredictApi = '$baseUrl/api/predict/disease/';

  // ---------------------------------------------------------------------------
  // Notifications
  // NOTE: live backend exposes these endpoints without /api prefix.
  // ---------------------------------------------------------------------------
  static const String notificationsApi = '$baseUrl/notifications/';
  static const String notificationCountApi = '$baseUrl/notifications/unread-count/';

  // ---------------------------------------------------------------------------
  // IoT APIs
  // ---------------------------------------------------------------------------
  static const String iotLiveApi = '$baseUrl/api/iot/live/';
  static const String iotHistoryApi = '$baseUrl/api/iot/history/';

  // ---------------------------------------------------------------------------
  // Weather API - no key needed
  // Gujranwala coordinates used as project default.
  // ---------------------------------------------------------------------------
  static const double defaultLatitude = 32.1877;
  static const double defaultLongitude = 74.1945;
  static const String defaultCity = 'Gujranwala';

  static String openMeteoWeatherUrl({
    double latitude = defaultLatitude,
    double longitude = defaultLongitude,
  }) {
    return 'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,weather_code'
        '&timezone=auto';
  }

  // ---------------------------------------------------------------------------
  // Network
  // ---------------------------------------------------------------------------
  static const Duration requestTimeout = Duration(seconds: 20);
  static const double defaultPadding = 16.0;
}
