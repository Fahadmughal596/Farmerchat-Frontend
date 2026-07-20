import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:dashboard_screen/models/market_rate_model.dart';
import 'package:dashboard_screen/models/notification_model.dart';
import 'package:dashboard_screen/utility/app_constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 20);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'access_token') ?? await _storage.read(key: 'token');
    final cookie = await _storage.read(key: 'session_cookie');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty && token != 'session') 'Authorization': 'Bearer $token',
      if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};
  }

  double _toDouble(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  // ---------------------------------------------------------------------------
  // WEATHER - Open-Meteo public API, no API key required
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchWeather({
    double latitude = AppConstants.defaultLatitude,
    double longitude = AppConstants.defaultLongitude,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.openMeteoWeatherUrl(latitude: latitude, longitude: longitude)))
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return {'success': false, 'message': 'Weather unavailable'};
      }

      final body = _decode(response);
      final current = Map<String, dynamic>.from(body['current'] ?? {});
      final hourly = Map<String, dynamic>.from(body['hourly'] ?? {});

      final temperature = _toDouble(current['temperature_2m']);
      final humidity = _toDouble(current['relative_humidity_2m']);
      final precipitation = _toDouble(current['precipitation']);
      final windSpeed = _toDouble(current['wind_speed_10m']);
      final weatherCode = int.tryParse(current['weather_code']?.toString() ?? '') ?? 0;

      return {
        'success': true,
        'city': AppConstants.defaultCity,
        'temperature': temperature,
        'humidity': humidity,
        'precipitation': precipitation,
        'wind_speed': windSpeed,
        'weather_code': weatherCode,
        'condition': _weatherCondition(weatherCode),
        'time': current['time']?.toString() ?? '',
        'rain_probability': _extractRainProbability(hourly),
      };
    } catch (e) {
      // ignore: avoid_print
      print('fetchWeather Error: $e');
      return {'success': false, 'message': 'Weather connection failed'};
    }
  }

  String _weatherCondition(int code) {
    if (code == 0) return 'Clear';
    if ([1, 2, 3].contains(code)) return 'Partly cloudy';
    if ([45, 48].contains(code)) return 'Fog';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rain';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snow';
    if ([95, 96, 99].contains(code)) return 'Thunderstorm';
    return 'Weather';
  }

  int _extractRainProbability(Map<String, dynamic> hourly) {
    try {
      final values = hourly['precipitation_probability'];
      if (values is List && values.isNotEmpty) {
        return int.tryParse(values.first.toString()) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS
  // ---------------------------------------------------------------------------
  Future<List<NotificationModel>> getNotifications() async {
    final list = <NotificationModel>[];

    try {
      final response = await http
          .get(Uri.parse(AppConstants.notificationsApi), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = _decode(response);
        final raw = body['notifications'] ?? body['data'] ?? [];
        if (raw is List) {
          list.addAll(raw
              .whereType<Map>()
              .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e))));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('getNotifications Error: $e');
    }

    // Add demo-safe local weather notifications when backend has no alerts yet.
    final weather = await fetchWeather();
    list.insertAll(0, _localWeatherAlerts(weather));

    return list;
  }

  List<NotificationModel> _localWeatherAlerts(Map<String, dynamic> weather) {
    if (weather['success'] != true) return [];

    final alerts = <NotificationModel>[];
    final temp = _toDouble(weather['temperature']);
    final humidity = _toDouble(weather['humidity']);
    final rain = int.tryParse(weather['rain_probability']?.toString() ?? '') ?? 0;
    final wind = _toDouble(weather['wind_speed']);

    void add(String title, String message, String type, String priority) {
      alerts.add(NotificationModel(
        id: -alerts.length - 1,
        title: title,
        message: message,
        notificationType: type,
        priority: priority,
        action: 'weather',
        isRead: false,
        createdAt: 'Live weather',
      ));
    }

    if (temp >= 38) {
      add('🌡 Heat Alert', 'Temperature is ${temp.toStringAsFixed(0)}°C. Irrigation timing and crop protection should be checked.', 'weather', 'high');
    }
    if (rain >= 45) {
      add('🌧 Rain Alert', 'Rain probability is $rain%. Avoid pesticide spray and protect machinery.', 'weather', 'high');
    }
    if (humidity >= 80) {
      add('🍄 Disease Risk', 'Humidity is ${humidity.toStringAsFixed(0)}%. Fungal disease risk may increase.', 'weather', 'normal');
    }
    if (wind >= 25) {
      add('💨 Wind Alert', 'Wind speed is ${wind.toStringAsFixed(0)} km/h. Avoid spraying pesticides.', 'weather', 'normal');
    }

    return alerts;
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.notificationCountApi), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = _decode(response);
        final count = body['unread_count'] ?? body['count'] ?? 0;
        return int.tryParse(count.toString()) ?? 0;
      }
    } catch (e) {
      // ignore: avoid_print
      print('getUnreadCount Error: $e');
    }

    final localAlerts = _localWeatherAlerts(await fetchWeather());
    return localAlerts.length;
  }

  Future<bool> markNotificationRead(int id) async {
    if (id < 0) return true;

    try {
      final response = await http
          .get(Uri.parse('${AppConstants.notificationsApi}$id/read/'), headers: await _headers())
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('markNotificationRead Error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // MARKET RATES
  // ---------------------------------------------------------------------------
  Future<List<MarketRateModel>> fetchMarketRates({String? crop, String? region, String? mandi}) async {
    try {
      final uri = Uri.parse(AppConstants.marketRatesApi).replace(queryParameters: {
        if (crop != null && crop.trim().isNotEmpty) 'crop': crop.trim(),
        if (region != null && region.trim().isNotEmpty) 'region': region.trim(),
        if (mandi != null && mandi.trim().isNotEmpty) 'mandi': mandi.trim(),
      });

      final response = await http.get(uri, headers: await _headers()).timeout(_timeout);

      if (response.statusCode == 200) {
        final body = _decode(response);
        final rates = body['rates'] ?? body['data'] ?? [];
        if (rates is List) {
          return rates
              .whereType<Map>()
              .map((item) => MarketRateModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('fetchMarketRates Error: $e');
    }

    return [];
  }

  // ---------------------------------------------------------------------------
  // CHATBOT / AI FARMING GUIDANCE
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // CROP DISEASE DETECTION - uploads a leaf photo, backend runs the
  // Hugging Face image-classification model and returns the predicted
  // disease name + confidence score.
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> predictDisease({required File imageFile}) async {
    try {
      final uri = Uri.parse(AppConstants.diseasePredictApi);
      final request = http.MultipartRequest('POST', uri);

      final headers = await _headers();
      headers.remove('Content-Type'); // let http set multipart boundary itself
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return _decode(response);
      }

      return {
        'success': false,
        'label': null,
        'confidence': 0.0,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      // ignore: avoid_print
      print('predictDisease Error: $e');
      return {
        'success': false,
        'label': null,
        'confidence': 0.0,
        'message': 'Connection failed. Please check internet or backend URL.',
      };
    }
  }

  Future<Map<String, dynamic>> sendChatMessage({required String message, String language = 'en'}) async {
    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.chatbotApi),
            headers: await _headers(),
            body: jsonEncode({'message': message, 'language': language}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return _decode(response);
      }

      return {
        'success': false,
        'intent': 'error',
        'reply': 'Server error: ${response.statusCode}',
        'data': [],
      };
    } catch (e) {
      // ignore: avoid_print
      print('sendChatMessage Error: $e');
      return {
        'success': false,
        'intent': 'error',
        'reply': 'Connection failed. Please check internet or backend URL.',
        'data': [],
      };
    }
  }

  // ---------------------------------------------------------------------------
  // GOVERNMENT SCHEMES
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchGovernmentSchemes({String? region, String? category, String? status}) async {
    try {
      final uri = Uri.parse(AppConstants.schemesApi).replace(queryParameters: {
        if (region != null && region.trim().isNotEmpty) 'region': region.trim(),
        if (category != null && category.trim().isNotEmpty) 'category': category.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      });

      final response = await http.get(uri, headers: await _headers()).timeout(_timeout);

      if (response.statusCode == 200) return _decode(response);
    } catch (e) {
      // ignore: avoid_print
      print('fetchGovernmentSchemes Error: $e');
    }

    return {'success': false, 'schemes': [], 'message': 'Connection failed'};
  }

  // ---------------------------------------------------------------------------
  // IOT LIVE / HISTORY
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchIoTLive() async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.iotLiveApi), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = _decode(response);
        if (body['reading'] is Map) {
          return {'success': true, 'reading': Map<String, dynamic>.from(body['reading'])};
        }
        return body;
      }
    } catch (e) {
      // ignore: avoid_print
      print('fetchIoTLive Error: $e');
    }

    return {
      'success': false,
      'message': 'IoT sensors are not connected yet.',
      'reading': null,
    };
  }

  Future<Map<String, dynamic>> fetchIoTHistory() async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.iotHistoryApi), headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 200) return _decode(response);
    } catch (e) {
      // ignore: avoid_print
      print('fetchIoTHistory Error: $e');
    }

    return {'success': false, 'readings': []};
  }

  // ---------------------------------------------------------------------------
  // AI FIELD PREDICTION - derived from real IoT data when available, otherwise weather only.
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchFieldPrediction() async {
    final iot = await fetchIoTLive();
    final weather = await fetchWeather();

    final reading = Map<String, dynamic>.from(iot['reading'] ?? {});

    final moisture = _toDouble(reading['moisture']);
    final soilTemp = _toDouble(reading['temperature']);
    final sensorHumidity = _toDouble(reading['humidity']);

    final temp = _toDouble(weather['temperature'], soilTemp);
    final humidity = _toDouble(weather['humidity'], sensorHumidity);
    final rainProbability = int.tryParse(weather['rain_probability']?.toString() ?? '') ?? 0;

    final risks = <String>[];
    final actions = <String>[];

    if (moisture > 0 && moisture < 30) {
      risks.add('Low soil moisture');
      actions.add('Irrigate the field soon, preferably early morning or evening.');
    } else if (moisture > 85) {
      risks.add('Water logging risk');
      actions.add('Avoid irrigation and improve drainage.');
    }

    if (temp >= 38) {
      risks.add('Heat stress');
      actions.add('Use light irrigation and avoid pesticide spray during peak heat.');
    }

    if (humidity >= 80 || rainProbability >= 50) {
      risks.add('Fungal disease risk');
      actions.add('Monitor leaves for spots/yellowing and avoid unnecessary watering.');
    }

    if (actions.isEmpty) {
      risks.add('Normal condition');
      actions.add('Field condition looks stable. Continue regular monitoring.');
    }

    return {
      'success': true,
      'title': risks.first,
      'risk_level': risks.any((e) => e.contains('stress') || e.contains('disease') || e.contains('Low')) ? 'Medium' : 'Low',
      'summary': risks.join(' • '),
      'recommendation': actions.join(' '),
      'source': reading.isNotEmpty ? 'IoT + Weather' : 'Weather only',
    };
  }
}
