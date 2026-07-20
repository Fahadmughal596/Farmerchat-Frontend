import 'package:flutter/material.dart';

import 'package:dashboard_screen/utility/app_constants.dart';

import 'package:dashboard_screen/features/admin/presentation/screens/admin_mandi_rates.dart';
import 'package:dashboard_screen/features/admin/presentation/screens/admin_settings.dart';
import 'package:dashboard_screen/features/admin/presentation/screens/help_desk.dart';
import 'package:dashboard_screen/features/admin/presentation/screens/users_request_handling.dart';

import 'package:dashboard_screen/views/ai_chat_screen.dart';
import 'package:dashboard_screen/views/govt_scheme_screen.dart';
import 'package:dashboard_screen/views/iot_sensors_screen.dart';
import 'package:dashboard_screen/views/market_rates_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // ================= NAV HELPER =================
  void _go(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,

      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Admin Dashboard / ایڈمن ڈیش بورڈ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeHeader(),
            const SizedBox(height: 24),

            const Text(
              'MAIN TOOLS / اہم ٹولز',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _adminCard(
                  context,
                  'User Requests',
                  'صارفین کی درخواستیں',
                  Icons.person_add,
                  Colors.blue,
                  () => _go(context, const UserRequestHandling()),
                ),
                _adminCard(
                  context,
                  'Mandi Rates',
                  'منڈی ریٹس',
                  Icons.trending_up,
                  Colors.orange,
                  () => _go(context, const AdminMandiRates()),
                ),
                _adminCard(
                  context,
                  'Settings',
                  'سیٹنگز',
                  Icons.settings,
                  Colors.blueGrey,
                  () => _go(context, const AdminSettings()),
                ),
                _adminCard(
                  context,
                  'Help Desk',
                  'ہیلپ ڈیسک',
                  Icons.contact_support,
                  Colors.teal,
                  () => _go(context, const HelpDesk()),
                ),
              ],
            ),

            const SizedBox(height: 26),

            const Text(
              'LIVE MODULES / لائیو ماڈیولز',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _adminCard(
                  context,
                  'AI Chatbot',
                  'اے آئی چیٹ',
                  Icons.smart_toy,
                  Colors.deepOrange,
                  () => _go(context, const AiChatScreen()),
                ),
                _adminCard(
                  context,
                  'Govt Schemes',
                  'سرکاری اسکیمیں',
                  Icons.account_balance,
                  Colors.brown,
                  () => _go(context, const GovtSchemeScreen()),
                ),
                _adminCard(
                  context,
                  'IoT Sensors',
                  'آئی او ٹی سینسرز',
                  Icons.sensors,
                  Colors.purple,
                  () => _go(context, const IotSensorsScreen()),
                ),
                _adminCard(
                  context,
                  'Market Rates',
                  'مارکیٹ ریٹس',
                  Icons.storefront,
                  Colors.green,
                  () => _go(context, const MarketRatesScreen()),
                ),
              ],
            ),

            const SizedBox(height: 26),

            const Text(
              'STATISTICS / رپورٹ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 10),

            _statTile('Total Farmers', 'کل کسان', '1,240'),
            _statTile('Pending Requests', 'پینڈنگ رجسٹریشن', '15'),
            _statTile('Live Backend', 'آن لائن سرور', 'Active'),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppConstants.primaryGreen.withOpacity(0.08),
                ),
              ),
              child: const Text(
                'Backend: https://fareedse.pythonanywhere.com',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _welcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppConstants.secondaryGreen,
            AppConstants.primaryGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Admin!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'خوش آمدید، ایڈمن!',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _adminCard(
    BuildContext context,
    String eng,
    String urdu,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              eng,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              urdu,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String engLabel, String urduLabel, String count) {
    return Card(
      child: ListTile(
        title: Text(engLabel),
        subtitle: Text(urduLabel),
        trailing: Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryGreen,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}