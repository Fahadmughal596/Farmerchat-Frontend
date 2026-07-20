import 'package:flutter/material.dart';


class FarmerRequestGate extends StatelessWidget {
  final String name;
  final String specialty;

  const FarmerRequestGate({
    super.key,
    required this.name,
    required this.specialty,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B4332);
    const Color bgCream = Color(0xFFF9F3E5);

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text("Request Detail / درخواست کی تفصیل",
            style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryGreen,
                    child: Text(
                        name.isNotEmpty ? name[0] : "E",
                        style: const TextStyle(color: Colors.white, fontSize: 40)
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen)
                  ),
                  const SizedBox(height: 8),
                  Text(
                      specialty,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Column(
                  children: [
                    Text(
                      "Assalam-o-Alaikum! I am an agricultural expert. I want to help you improve your crop yield.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "السلام علیکم! میں ایک ماہر زراعت ہوں۔ میں آپ کی فصل کی پیداوار بہتر بنانے میں آپ کی مدد کرنا چاہتا ہوں۔",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.bold, color: primaryGreen),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ACCEPT BUTTON
                SizedBox(
                  width: 150,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Request Accepted! Opening Chat..."),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Accept", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("قبول کریں", style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),

                // IGNORE BUTTON
                SizedBox(
                  width: 150,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Ignore", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        Text("نظر انداز کریں", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}