import 'package:flutter/material.dart';
import 'request_gate_screen.dart';

class FarmerRequestList extends StatelessWidget {
  const FarmerRequestList({super.key});

  // Manual Data Updated with more names and fixed syntax
  final List<Map<String, String>> requests = const [
    {"name": "Abdullah", "specialty": "Wheat Specialist", "initial": "A"},
    {"name": "Hamza", "specialty": "Soil Scientist", "initial": "H"},
    {"name": "Ali", "specialty": "Pesticide Expert", "initial": "A"},
    {"name": "Arslan", "specialty": "Weather Analyst", "initial": "A"}, // Added missing comma
    {"name": "Saad", "specialty": "Cotton Consultant", "initial": "S"},
    {"name": "Bilal", "specialty": "Crop Pathologist", "initial": "B"},
    {"name": "Hassan", "specialty": "Agri-Tech Specialist", "initial": "H"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E5), // Dashboard se match karne ke liye background color
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Expert Requests / درخواستیں", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1B4332),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1B4332),
              child: Text(requests[index]['initial']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(requests[index]['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(requests[index]['specialty']!,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmerRequestGate(
                    name: requests[index]['name']!,
                    specialty: requests[index]['specialty']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}