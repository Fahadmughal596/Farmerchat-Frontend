import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dashboard_screen/services/api_services.dart';
import 'package:dashboard_screen/utility/app_constants.dart';
import 'package:dashboard_screen/views/sign_in_screen.dart';

import 'notification_screen.dart';
import 'crops_history.dart';
import 'farm_profile_screen.dart';
import 'settings_screen.dart';
import 'rquest_help_screen/request_list_screen.dart';

import '../../../../views/ai_chat_screen.dart';
import '../../../../views/govt_scheme_screen.dart';
import '../../../../views/iot_sensors_screen.dart';
import '../../../../views/market_rates_screen.dart';
import '../../../../views/payment_plans_screen.dart';
import '../../../../views/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _weather;
  Map<String, dynamic>? _iot;
  Map<String, dynamic>? _prediction;
  bool _loading = true;
  int unreadCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) => _loadDashboard(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);

    final results = await Future.wait([
      _apiService.fetchWeather(),
      _apiService.fetchIoTLive(),
      _apiService.fetchFieldPrediction(),
      _apiService.getUnreadCount(),
    ]);

    if (!mounted) return;
    setState(() {
      _weather = results[0] as Map<String, dynamic>;
      _iot = results[1] as Map<String, dynamic>;
      _prediction = results[2] as Map<String, dynamic>;
      unreadCount = results[3] as int;
      _loading = false;
    });
  }

  Future<void> _refreshDashboard() async => _loadDashboard(silent: true);

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatValue(dynamic value, String suffix) {
    final number = _toDouble(value);
    if (number <= 0) return '--';
    final formatted = number.truncateToDouble() == number ? number.toStringAsFixed(0) : number.toStringAsFixed(1);
    return '$formatted$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      appBar: AppBar(
        title: const Text('FarmerChat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                  if (mounted) await _loadDashboard(silent: true);
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 10,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(onPressed: _refreshDashboard, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        color: AppConstants.primaryGreen,
        onRefresh: _refreshDashboard,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryGreen))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(),
                    _buildWeatherCard(),
                    _buildPredictionCard(),
                    _buildQuickActions(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Text('Smart Farm Overview ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
                          Text('(فوری جائزہ)', style: TextStyle(fontSize: 15, color: Colors.grey)),
                        ],
                      ),
                    ),
                    _buildOverviewSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppConstants.bgCream,
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppConstants.primaryGreen),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: AppConstants.primaryGreen, size: 40)),
            accountName: Text('Farmer User', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text('Verified Farmer'),
          ),
          _sidebarItem(context, Icons.history, 'Crops History', 'فصلوں کا ریکارڈ', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CropsHistory()));
          }),
          _sidebarItem(context, Icons.agriculture, 'Farm Profile', 'فارم پروفائل', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmProfileScreen()));
          }),
          _sidebarItem(context, Icons.person_add_alt_1, 'Connection Requests', 'رابطہ کی درخواستیں', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerRequestList()));
          }),
          _sidebarItem(context, Icons.workspace_premium, 'Premium Plan', 'پریمیم پلان', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentPlansScreen()));
          }),
          _sidebarItem(context, Icons.settings, 'Settings', 'ترتیبات', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          const Divider(),
          _sidebarItem(context, Icons.exit_to_app, 'Logout', 'لاگ آؤٹ', () => _showLogoutDialog(context)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to logout?\nکیا آپ لاگ آؤٹ کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _authService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppConstants.primaryGreen.withOpacity(.22), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.eco, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome Farmer', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('AI + IoT based agricultural support', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final weather = _weather ?? {};
    final success = weather['success'] == true;

    final temp = success ? _formatValue(weather['temperature'], '°C') : '--';
    final humidity = success ? _formatValue(weather['humidity'], '%') : '--';
    final condition = success ? (weather['condition']?.toString() ?? 'Weather') : 'Weather unavailable';
    final rain = success ? '${weather['rain_probability'] ?? 0}%' : '--';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppConstants.primaryGreen.withOpacity(.08))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFFFF4E5), child: Icon(Icons.wb_sunny, color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weather · ${AppConstants.defaultCity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
                    const Text('Auto refreshes every 1 minute', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Text(temp, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(Icons.cloud, condition, Colors.blueGrey),
              _pill(Icons.water_drop, 'Humidity $humidity', Colors.blue),
              _pill(Icons.umbrella, 'Rain $rain', Colors.indigo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard() {
    final p = _prediction ?? {};
    final title = p['title']?.toString() ?? 'AI Field Prediction';
    final risk = p['risk_level']?.toString() ?? 'Low';
    final summary = p['summary']?.toString() ?? 'Field condition is being analyzed.';
    final recommendation = p['recommendation']?.toString() ?? 'Continue regular monitoring.';

    final color = risk.toLowerCase().contains('high') ? Colors.red : risk.toLowerCase().contains('medium') ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppConstants.primaryGreen, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Expanded(child: Text('Latest AI Field Prediction', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text(risk, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(summary, style: const TextStyle(color: Colors.white70, height: 1.35)),
          const SizedBox(height: 10),
          Text('Recommended Action: $recommendation', style: const TextStyle(color: Colors.white, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        children: [
          _buildMenuCard(context, 'Agri Dost AI', Icons.smart_toy, const AiChatScreen(), 'ایگری دوست (چیٹ)', Colors.orange),
          _buildMenuCard(context, 'Mandi Rates', Icons.trending_up, const MarketRatesScreen(), 'منڈی ریٹ', Colors.green),
          _buildMenuCard(context, 'Govt Schemes', Icons.account_balance, const GovtSchemeScreen(), 'سرکاری اسکیمیں', Colors.brown),
          _buildMenuCard(context, 'Smart Farm (IoT)', Icons.sensors, const IotSensorsScreen(), 'سینسرز', Colors.teal),
          _buildMenuCard(context, 'Premium Plan', Icons.workspace_premium, const PaymentPlansScreen(), 'پریمیم', Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    final body = _iot ?? {};
    final reading = Map<String, dynamic>.from(body['reading'] ?? {});

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _metricCard(Icons.water_drop, 'Soil Moisture', _formatValue(reading['moisture'], '%'), Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard(Icons.thermostat, 'Temperature', _formatValue(reading['temperature'], '°C'), Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard(Icons.opacity, 'Humidity', _formatValue(reading['humidity'], '%'), Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard(Icons.sensors, 'Device', reading['device_id']?.toString() ?? '--', Colors.purple)),
            ],
          ),
          if (reading.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('IoT sensors are not connected yet. Connect ESP32 sensors to show live readings.', style: TextStyle(fontSize: 12, color: Colors.black45)),
            ),
        ],
      ),
    );
  }

  Widget _metricCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(.12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 15, color: color), const SizedBox(width: 5), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12))],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget screen, String urdu, Color col) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: col.withOpacity(.12))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: col.withOpacity(.1), child: Icon(icon, color: col)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(urdu, style: const TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(BuildContext context, IconData icon, String title, String urduText, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: AppConstants.primaryGreen), title: Text(title), subtitle: Text(urduText), onTap: onTap);
  }
}
