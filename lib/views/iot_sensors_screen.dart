import 'package:flutter/material.dart';

import 'package:dashboard_screen/services/api_services.dart';
import 'package:dashboard_screen/utility/app_constants.dart';

class IotSensorsScreen extends StatefulWidget {
  const IotSensorsScreen({super.key});

  @override
  State<IotSensorsScreen> createState() => _IotSensorsScreenState();
}

class _IotSensorsScreenState extends State<IotSensorsScreen> {
  final ApiService _apiService = ApiService();

  late Future<Map<String, dynamic>> _liveFuture;

  @override
  void initState() {
    super.initState();
    _liveFuture = _apiService.fetchIoTLive();
  }

  void _refreshData() {
    setState(() {
      _liveFuture = _apiService.fetchIoTLive();
    });
  }

double _toDouble(dynamic value) {
  if (value == null) return 0;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}

  String _formatValue(dynamic value, String suffix) {
  final number = _toDouble(value);

  return number % 1 == 0
      ? '${number.toInt()}$suffix'
      : '${number.toStringAsFixed(1)}$suffix';
}

  String _moistureStatus(double value) {
    if (value <= 0) return 'No Data';
    if (value < 30) return 'Low';
    if (value > 85) return 'High';
    return 'Normal';
  }

  String _temperatureStatus(double value) {
    if (value <= 0) return 'No Data';
    if (value > 40) return 'Critical';
    if (value > 33) return 'High';
    return 'Normal';
  }

  String _humidityStatus(double value) {
    if (value <= 0) return 'No Data';
    if (value < 40) return 'Low';
    if (value > 88) return 'High';
    return 'Normal';
  }

  Color _statusColor(String status) {
    if (status == 'Normal') return Colors.green;
    if (status == 'No Data') return Colors.grey;
    if (status == 'Critical') return Colors.red;
    return Colors.orange;
  }

  String _irrigationAdvice(double moisture) {
    if (moisture <= 0) return 'No moisture data is available yet.';
    if (moisture < 30) return 'Soil moisture is low. Irrigation is recommended soon.';
    if (moisture > 85) return 'Soil moisture is very high. Avoid over-irrigation.';
    return 'Soil moisture is in a suitable range.';
  }

  String _irrigationAdviceUrdu(double moisture) {
    if (moisture <= 0) return 'ابھی نمی کا ڈیٹا دستیاب نہیں۔';
    if (moisture < 30) return 'زمین کی نمی کم ہے، جلد پانی دیں۔';
    if (moisture > 85) return 'زمین میں نمی زیادہ ہے، مزید پانی نہ دیں۔';
    return 'زمین کی نمی مناسب حد میں ہے۔';
  }

  String _temperatureAdvice(double temperature) {
    if (temperature <= 0) return 'No temperature data is available yet.';
    if (temperature > 40) return 'Temperature is critical. Crops may face heat stress.';
    if (temperature > 33) return 'Temperature is slightly high. Monitor crop condition.';
    return 'Temperature is favorable for crops.';
  }

  String _temperatureAdviceUrdu(double temperature) {
    if (temperature <= 0) return 'ابھی درجہ حرارت کا ڈیٹا دستیاب نہیں۔';
    if (temperature > 40) return 'درجہ حرارت بہت زیادہ ہے، فصل متاثر ہو سکتی ہے۔';
    if (temperature > 33) return 'درجہ حرارت کچھ زیادہ ہے، فصل کی نگرانی کریں۔';
    return 'درجہ حرارت فصلوں کے لیے مناسب ہے۔';
  }

  String _humidityAdvice(double humidity) {
    if (humidity <= 0) return 'No humidity data is available yet.';
    if (humidity > 88) return 'Humidity is high. Fungal disease risk may increase.';
    if (humidity < 40) return 'Humidity is low. Crop stress risk may increase.';
    return 'Humidity is in a suitable range.';
  }

  String _humidityAdviceUrdu(double humidity) {
    if (humidity <= 0) return 'ابھی ہوا کی نمی کا ڈیٹا دستیاب نہیں۔';
    if (humidity > 88) return 'ہوا میں نمی زیادہ ہے، فنگس کا خطرہ بڑھ سکتا ہے۔';
    if (humidity < 40) return 'ہوا میں نمی کم ہے، فصل پر دباؤ آ سکتا ہے۔';
    return 'ہوا کی نمی مناسب حد میں ہے۔';
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    final deviceId = data['device_id']?.toString() ?? 'Latest Device';
    final farmName = data['farm_name']?.toString() ?? 'Smart Farm';
    final location = data['location']?.toString() ?? 'Field';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Farm (IoT)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'سمارٹ فارم (آئی او ٹی)',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.sensors, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$deviceId · $farmName · $location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (data['timestamp'] != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Last updated: ${data['timestamp']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _sensorChartCard({
    required String title,
    required String urduTitle,
    required String value,
    required Color color,
    required String status,
    required IconData icon,
    required double progress,
    String? extraValue,
  }) {
    final statusColor = _statusColor(status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(urduTitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            if (extraValue != null)
              Text(
                extraValue,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 9,
                value: progress.clamp(0, 1),
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 82,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Icon(Icons.show_chart, color: color, size: 42),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adviceCard(String title, String eng, String urdu, IconData icon, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(eng, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            Text(
              urdu,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors_off, size: 64, color: AppConstants.primaryGreen.withOpacity(0.35)),
            const SizedBox(height: 14),
            const Text(
              'No IoT Data Available',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final moisture = _toDouble(data['moisture']);
    final temperature = _toDouble(data['temperature']);
    final humidity = _toDouble(data['humidity']);

    return RefreshIndicator(
      color: AppConstants.primaryGreen,
      onRefresh: () async => _refreshData(),
      child: ListView(
        children: [
          _buildHeader(data),
          _sensorChartCard(
            title: 'Soil Moisture Sensor',
            urduTitle: 'زمین کی نمی سینسر',
            value: _formatValue(moisture, '%'),
            color: Colors.blue,
            status: _moistureStatus(moisture),
            icon: Icons.water_drop,
            progress: moisture / 100,
          ),
          _sensorChartCard(
            title: 'Temperature',
            urduTitle: 'درجہ حرارت',
            value: _formatValue(temperature, '°C'),
            color: Colors.orange,
            status: _temperatureStatus(temperature),
            icon: Icons.thermostat,
            progress: temperature / 50,
          ),
          _sensorChartCard(
            title: 'Humidity',
            urduTitle: 'ہوا کی نمی',
            value: _formatValue(humidity, '%'),
            color: Colors.purple,
            status: _humidityStatus(humidity),
            icon: Icons.air,
            progress: humidity / 100,
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Smart Advice ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '(مشورہ)',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _adviceCard(
            'Irrigation Advice',
            _irrigationAdvice(moisture),
            _irrigationAdviceUrdu(moisture),
            Icons.water_drop,
            Colors.blue,
          ),
          _adviceCard(
            'Temperature Advice',
            _temperatureAdvice(temperature),
            _temperatureAdviceUrdu(temperature),
            Icons.thermostat,
            Colors.orange,
          ),
          _adviceCard(
            'Humidity Advice',
            _humidityAdvice(humidity),
            _humidityAdviceUrdu(humidity),
            Icons.air,
            Colors.purple,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      appBar: AppBar(
        title: const Text(
          'Smart Farm (IoT)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _liveFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryGreen,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _emptyState('Unable to connect with the IoT server.');
          }

          final response = snapshot.data!;

if (response['success'] != true) {
  return _emptyState(
    response['message']?.toString() ??
        'No sensor data available yet.',
  );
}

final data = response['data'] is Map<String, dynamic>
    ? Map<String, dynamic>.from(response['data'])
    : response;

return _buildContent(data);
        },
      ),
    );
  }
}