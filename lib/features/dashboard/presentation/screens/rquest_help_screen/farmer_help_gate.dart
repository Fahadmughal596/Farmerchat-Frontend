import 'package:flutter/material.dart';

class FarmerHelpGate extends StatefulWidget {
  final String name;
  final String specialty;

  const FarmerHelpGate({
    super.key,
    required this.name,
    required this.specialty
  });

  @override
  State<FarmerHelpGate> createState() => _FarmerHelpGateState();
}

class _FarmerHelpGateState extends State<FarmerHelpGate> {
  final TextEditingController _messageController = TextEditingController();
  final Color primaryGreen = const Color(0xFF1B4332);

  void _sendRequest() {
    if (_messageController.text.isNotEmpty) {
      // Yahan request send karne ka logic aayega
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request sent to ${widget.specialty}!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Request bhej kar wapas chale jana
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your query first / پہلے اپنا سوال لکھیں")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Request Expert Help", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expert Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: Icon(Icons.psychology, color: primaryGreen, size: 35),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name, // "Expert" ya naam jo bhi pass kiya jaye
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.specialty,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Describe your problem / اپنا مسئلہ بیان کریں",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Message Input
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter details here... / یہاں تفصیلات لکھیں",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "SEND REQUEST / درخواست بھیجیں",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}