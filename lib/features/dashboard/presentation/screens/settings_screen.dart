import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dashboard_screen/views/sign_in_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ================= STATES =================
  bool isDarkMode = false;
  bool isOfflineMode = false;
  bool isLocationEnabled = true;
  bool isPasswordSaved = true;
  bool showActivityStatus = true;
  bool weatherAlerts = true;

  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color bgCream = Color(0xFFF9F3E5);

  final storage = const FlutterSecureStorage();

  // ================= THEME =================
  Color get currentBg => isDarkMode ? Colors.black87 : bgCream;
  Color get textColor => isDarkMode ? Colors.white : Colors.black87;

  // ================= LOGOUT (FIXED) =================
  Future<void> _logout() async {
    await storage.deleteAll();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentBg,

      appBar: AppBar(
        title: const Text(
          "Settings (ترتیبات)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView(
        children: [
          // ================= SECTION 1 =================
          _sectionHeader("Preferences (ترجیحات)", textColor),

          _settingsTile(
            Icons.language,
            "App Language",
            "ایپ کی زبان (English / Urdu)",
            textColor,
            () => _showLanguageDialog(context),
          ),

          _switchTile(
            Icons.cloud_off_outlined,
            "Offline Mode",
            "انٹرنیٹ کے بغیر استعمال کریں",
            isOfflineMode,
            textColor,
            (v) => setState(() => isOfflineMode = v),
          ),

          const Divider(),

          // ================= SECTION 2 =================
          _sectionHeader("Farm's Location (کھیت کا مقام)", textColor),

          _switchTile(
            Icons.location_on_outlined,
            "Location Access",
            "کھیت کے مقام کی رسائی",
            isLocationEnabled,
            textColor,
            (v) => setState(() => isLocationEnabled = v),
          ),

          _switchTile(
            Icons.circle,
            "Activity Status",
            "آن لائن ہونے کی معلومات",
            showActivityStatus,
            textColor,
            (v) => setState(() => showActivityStatus = v),
          ),

          const Divider(),

          // ================= SECTION 3 =================
          _sectionHeader("Security & Notifications (حفاظت)", textColor),

          _switchTile(
            Icons.lock_outline,
            "Save Password",
            "لاگ ان کی معلومات محفوظ کریں",
            isPasswordSaved,
            textColor,
            (v) => setState(() => isPasswordSaved = v),
          ),

          _switchTile(
            Icons.wb_sunny_outlined,
            "Weather Alerts",
            "موسم کی اطلاع",
            weatherAlerts,
            textColor,
            (v) => setState(() => weatherAlerts = v),
          ),

          const Divider(),

          // ================= SECTION 4 =================
          _sectionHeader("Support & Legal", textColor),

          _settingsTile(
            Icons.security,
            "Privacy Policy",
            "رازداری کی پالیسی",
            textColor,
            () => _showPolicyDialog(context),
          ),

          const SizedBox(height: 30),

          _logoutButton(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= PRIVACY DIALOG =================
  void _showPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.verified_user_outlined,
                color: primaryGreen, size: 40),
            SizedBox(height: 10),
            Text("Privacy Policy",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("(رازداری کی پالیسی)",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        content: const Text(
          "Your data is protected and not shared with third parties.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ================= LANGUAGE =================
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text("Urdu"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT =================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _sectionHeader(String title, Color tColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title,
    String subtitle,
    Color tColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: primaryGreen),
      title: Text(title, style: TextStyle(color: tColor)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _switchTile(
    IconData icon,
    String title,
    String subtitle,
    bool val,
    Color tColor,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: primaryGreen),
      title: Text(title, style: TextStyle(color: tColor)),
      subtitle: Text(subtitle),
      value: val,
      onChanged: onChanged,
      activeColor: primaryGreen,
    );
  }

  Widget _logoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        onPressed: () => _showLogoutDialog(context),
      ),
    );
  }
}