import 'package:flutter/material.dart';

import 'package:dashboard_screen/utility/app_constants.dart';
import 'package:dashboard_screen/views/market_rates_screen.dart';

class AdminMandiRates extends StatelessWidget {
  const AdminMandiRates({super.key});

  static const String backendAdminUrl =
      'https://fareedse.pythonanywhere.com/market-rates/';

  static const String djangoAdminUrl =
      'https://fareedse.pythonanywhere.com/admin/core/marketrate/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        title: const Text(
          'Manage Mandi Rates',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _headerCard(),
          const SizedBox(height: 18),

          _infoCard(
            icon: Icons.storefront,
            title: 'Live Market Rates',
            subtitle:
                'View all published mandi rates coming from the deployed Django backend.',
            buttonText: 'Open Live Rates in App',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarketRatesScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _infoCard(
            icon: Icons.admin_panel_settings,
            title: 'Update Rates from Web Admin',
            subtitle:
                'For adding, editing, or deleting rates, use the Django admin panel or deployed web admin dashboard.',
            buttonText: 'Use Web Admin Panel',
            color: Colors.orange,
            onTap: () {
              _showAdminInfo(context);
            },
          ),

          const SizedBox(height: 20),

          _noticeBox(),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppConstants.secondaryGreen,
            AppConstants.primaryGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.trending_up, color: Colors.white, size: 34),
          SizedBox(height: 12),
          Text(
            'Mandi Rates Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'منڈی ریٹس مینجمنٹ',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 10),
          Text(
            'Rates shown in the mobile app come from your live Django backend database.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppConstants.primaryGreen.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
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
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppConstants.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mobile-side rate creation is not enabled yet because it needs secure admin authentication. For now, add and update rates from the Django web admin panel.',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Web Admin URLs',
          style: TextStyle(
            color: AppConstants.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Use these URLs in browser:\n\n'
          'Market Rates Dashboard:\n'
          'https://fareedse.pythonanywhere.com/market-rates/\n\n'
          'Django Admin Market Rates:\n'
          'https://fareedse.pythonanywhere.com/admin/core/marketrate/',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}