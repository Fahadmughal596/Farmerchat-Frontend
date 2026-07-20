import 'package:flutter/material.dart';

class ExpertHelpScreen extends StatelessWidget {
  const ExpertHelpScreen({super.key});

  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color bgCream = Color(0xFFF9F3E5);

  @override
  Widget build(BuildContext context) {
    // GestureDetector se khali jagah tap karne par keyboard band ho jayega
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgCream,
        // Keyboard khulne par layout ko distrub nahi hone dega
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Expert Help",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: primaryGreen,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const Icon(Icons.support_agent, size: 70, color: primaryGreen),
              const SizedBox(height: 10),
              const Text(
                "Agri Support Center",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
              const Text("اپنا مسئلہ یہاں لکھیں، ہمارے ماہرین آپ سے رابطہ کریں گے",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey)),

              const SizedBox(height: 25),

              // --- Message Input Box ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: const TextField(
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Describe your problem here... (اپنی مشکل یہاں لکھیں)",
                    hintStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Button dabate hi keyboard band ho jaye
                    FocusScope.of(context).unfocus();
                    _showSuccessDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Send Message", style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Quick Actions:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
              ),
              const SizedBox(height: 10),

              _helpTile(Icons.call, "Official Helpline", "Call 0800-12345 for urgent help"),
              _helpTile(Icons.menu_book, "Agri Guidebook", "Read expert articles and tips"),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Message Sent!"),
        content: const Text("Your request has been received. Our expert will contact you soon."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: primaryGreen))
          )
        ],
      ),
    );
  }

  Widget _helpTile(IconData icon, String title, String sub) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: primaryGreen),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        onTap: () {},
      ),
    );
  }
}