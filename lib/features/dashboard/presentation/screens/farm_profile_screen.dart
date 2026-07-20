import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  static const String baseUrl =
      "https://fareedse.pythonanywhere.com";

  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color bgCream = Color(0xFFF5F3E5);

  final storage = const FlutterSecureStorage();

  bool _loading = true;

  final TextEditingController nameC = TextEditingController();
  final TextEditingController farmC = TextEditingController();
  final TextEditingController locationC = TextEditingController();
  final TextEditingController landC = TextEditingController();
  final TextEditingController contactC = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // =========================
  // GET TOKEN
  // =========================
  Future<String?> getToken() async {
    return await storage.read(key: "access_token");
  }

  Future<Map<String, String>> get headers async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // =========================
  // LOAD PROFILE (API)
  // =========================
  Future<void> loadProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/profile/"),
        headers: await headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          nameC.text = data["full_name"] ?? "";
          farmC.text = data["farm_name"] ?? "";
          locationC.text = data["location"] ?? "";
          landC.text = data["total_land"] ?? "";
          contactC.text = data["contact"] ?? "";

          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint("Profile Load Error: $e");
      setState(() => _loading = false);
    }
  }

  // =========================
  // SAVE PROFILE (API READY)
  // =========================
  Future<void> saveProfile() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/profile/update/"),
        headers: await headers,
        body: jsonEncode({
          "full_name": nameC.text,
          "farm_name": farmC.text,
          "location": locationC.text,
          "total_land": landC.text,
          "contact": contactC.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Changes Saved Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Save failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Save Error: $e");
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    farmC.dispose();
    locationC.dispose();
    landC.dispose();
    contactC.dispose();
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgCream,
        appBar: AppBar(
          title: const Text(
            "Farm Profile (فارم پروفائل)",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryGreen,
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ================= HEADER =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: const BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 50, color: primaryGreen),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            nameC.text.isEmpty ? "User" : nameC.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildField("Full Name", nameC, Icons.person),
                          _buildField("Farm Name", farmC, Icons.agriculture),
                          _buildField("Location", locationC, Icons.location_on),
                          _buildField("Total Land", landC, Icons.landscape),
                          _buildField("Contact", contactC, Icons.phone),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ================= FIELD WIDGET =================
  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryGreen),
          border: InputBorder.none,
        ),
      ),
    );
  }
}