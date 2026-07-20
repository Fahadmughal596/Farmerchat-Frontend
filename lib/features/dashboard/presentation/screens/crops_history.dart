import 'package:flutter/material.dart';

class CropsHistory extends StatefulWidget {
  const CropsHistory({super.key});

  @override
  State<CropsHistory> createState() => _CropsHistoryState();
}

class _CropsHistoryState extends State<CropsHistory> {
  final Color primaryGreen = const Color(0xFF1B4332);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text("Crops History", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("(فصلوں کا ریکارڈ)", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Search Bar Section (Clean Header) ---
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 25, top: 10),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search Crops / فصل تلاش کریں...",
                prefixIcon: Icon(Icons.search, color: primaryGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- Simple Crops List Section ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCropTile("Wheat (گندم)", "Harvested", "Date: 12 Nov 2025", Colors.green),
                _buildCropTile("Cotton (کپاس)", "In Progress", "Date: 10 Aug 2025", Colors.orange),
                _buildCropTile("Rice (چاول)", "Sold", "Date: 15 Sep 2025", Colors.blue),
                _buildCropTile("Maize (مکئی)", "Growing", "Date: 05 Jan 2026", Colors.brown),
                _buildCropTile("Sugarcane (گنا)", "Harvested", "Date: 20 Oct 2025", Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Crop Tiles
  Widget _buildCropTile(String name, String status, String date, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.grass, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
              Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}