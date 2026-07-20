import 'package:flutter/material.dart';
import 'package:dashboard_screen/views/sign_in_screen.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  bool _notificationsEnabled = true;
  String currentLanguage = "English";
  final Color primaryGreen = const Color(0xFF1B4332);

  // --- 1. LOGOUT CONFIRMATION DIALOG ---
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Logout / لاگ آؤٹ"),
        content: const Text("Are you sure you want to logout?\nکیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 2. ACTUAL NAVIGATION TO SIGN IN ---
  void _performLogout() {
    _showSnackBar("Logged out successfully!");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Settings / ترتیبات",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildClickableHeader(),
          const SizedBox(height: 25),
          _sectionLabel("PREFERENCES / ترجیحات"),

          _settingTile(
            icon: Icons.translate,
            title: "App Language",
            subtitle: "Current: $currentLanguage",
            onTap: () => _showLanguagePicker(),
          ),

          _switchTile(
            icon: Icons.notifications_active_outlined,
            title: "Push Notifications",
            subtitle: "Manage system alerts",
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              _showSnackBar(val ? "Notifications Enabled" : "Notifications Disabled");
            },
          ),

          const SizedBox(height: 20),
          _sectionLabel("SECURITY & LEGAL / سیکیورٹی"),

          _settingTile(
            icon: Icons.lock_reset_rounded,
            title: "Change Password",
            subtitle: "Update your login credentials",
            onTap: () => _showPasswordForm(),
          ),

          _settingTile(
            icon: Icons.gavel_rounded,
            title: "Privacy Policy",
            subtitle: "Data handling & terms",
            onTap: () => _showPrivacyPolicy(),
          ),

          const SizedBox(height: 40),
          _logoutButton(),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---
  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text("LOGOUT / لاگ آؤٹ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            padding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
      ),
    );
  }

  Widget _buildClickableHeader() {
    return InkWell(
      onTap: () => _showEditProfile(),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(
                radius: 35,
                backgroundColor: primaryGreen,
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40)
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin Malaika", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("admin@iisat.edu.pk", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 5),
                  Text("Tap to edit profile / تبدیل کریں", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS & HELPERS ---
  void _showEditProfile() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(labelText: "Full Name")),
            TextField(decoration: InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () { Navigator.pop(ctx); _showSnackBar("Profile Updated!"); }, child: const Text("Save")),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("English"),
            onTap: () { setState(() => currentLanguage = "English"); Navigator.pop(ctx); },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Urdu / اردو"),
            onTap: () { setState(() => currentLanguage = "Urdu"); Navigator.pop(ctx); },
          ),
        ],
      ),
    );
  }

  void _showPasswordForm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Old Password")),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "New Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); _showSnackBar("Password Updated!"); }, child: const Text("Update")),
        ],
      ),
    );
  }

  // --- UPDATED PRIVACY POLICY ---
  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Privacy Policy / رازداری کی پالیسی",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
              ),
            ),
            const Divider(thickness: 1.5),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _PolicySection(
                      title: "1. Data Collection / ڈیٹا کا حصول",
                      content: "We collect basic profile details and crop requests to improve mandi services.\nہم منڈی کی خدمات کو بہتر بنانے کے لیے بنیادی پروفائل اور فصلوں کی درخواستیں جمع کرتے ہیں۔",
                    ),
                    _PolicySection(
                      title: "2. Usage / استعمال",
                      content: "Your data is only used for administrative purposes within this portal.\nآپ کا ڈیٹا صرف اس پورٹل کے اندر انتظامی مقاصد کے لیے استعمال کیا جاتا ہے۔",
                    ),
                    _PolicySection(
                      title: "3. Security / حفاظت",
                      content: "We do not share your personal information with third parties.\nہم آپ کی ذاتی معلومات کو کسی تیسرے فریق کے ساتھ شیئر نہیں کرتے۔",
                    ),
                    _PolicySection(
                      title: "4. Academic Project / تعلیمی منصوبہ",
                      content: "This app is part of an FYP at IISAT University.\nیہ ایپ IISAT یونیورسٹی میں فائنل ایئر پروجیکٹ کا حصہ ہے۔",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                child: const Text("I Understand / میں سمجھ گیا", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating)
    );
  }

  Widget _sectionLabel(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)));

  Widget _settingTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: primaryGreen.withOpacity(0.1), child: Icon(icon, color: primaryGreen, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  Widget _switchTile({required IconData icon, required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: primaryGreen,
      secondary: CircleAvatar(backgroundColor: primaryGreen.withOpacity(0.1), child: Icon(icon, color: primaryGreen, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    );
  }
}

// --- HELPER WIDGET FOR POLICY ---
class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}