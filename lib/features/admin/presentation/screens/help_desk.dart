import 'package:flutter/material.dart';

class HelpDesk extends StatefulWidget {
  const HelpDesk({super.key});

  @override
  State<HelpDesk> createState() => _HelpDeskState();
}

class _HelpDeskState extends State<HelpDesk> {
  // --- Data Variables (Inhein aap manually update kar sakein gi) ---
  int totalTickets = 15;
  int pendingTickets = 5;
  int fixedTickets = 10;

  final Color primaryGreen = const Color(0xFF1B4332);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Help Desk / سپورٹ", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("SUPPORT OVERVIEW (Tap boxes for details)"),

            // --- Responsive Stats Row ---
            Row(
              children: [
                _statBox("Total", totalTickets.toString(), Colors.blue, () {
                  _showActionDetails("Total Tickets", "Monitoring all incoming farmer complaints.", totalTickets, 1.0, Colors.blue);
                }),
                _statBox("Pending", pendingTickets.toString(), Colors.orange, () {
                  // Performance logic: Pending kitne hain total mein se
                  double perf = pendingTickets / totalTickets;
                  _showActionDetails("Pending Tickets", "Tasks that need immediate attention.", pendingTickets, perf, Colors.orange);
                }),
                _statBox("Fixed", fixedTickets.toString(), Colors.green, () {
                  // Performance logic: Fixed ratio
                  double perf = fixedTickets / totalTickets;
                  _showActionDetails("Fixed Tickets", "Resolved issues and farmer satisfaction.", fixedTickets, perf, Colors.green);
                }),
              ],
            ),

            const SizedBox(height: 30),
            _sectionLabel("QUICK CONTACT"),
            _contactTile(Icons.chat, "WhatsApp Admin", "Chat with Support Team"),
            _contactTile(Icons.phone, "Call Hotline", "0300-XXXXXXX"),

            const SizedBox(height: 30),
            _sectionLabel("RECENT TICKETS"),
            _ticketItem("#4502", "Mandi rate sync error", "New"),
            _ticketItem("#4499", "Profile update failed", "Fixed"),
          ],
        ),
      ),
    );
  }

  // --- 1. FUNCTION: ACTION & PERFORMANCE SHEET ---
  void _showActionDetails(String title, String actionDesc, int count, double performance, Color color) {
    TextEditingController editController = TextEditingController(text: count.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 10),

            // Action Description
            const Text("Action / مقصد:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(actionDesc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Performance Bar
            Text("Performance Indicator (${(performance * 100).toInt()}%):", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: performance,
              backgroundColor: color.withOpacity(0.1),
              color: color,
              minHeight: 10,
            ),
            const SizedBox(height: 25),

            // Manual Edit Section
            const Text("Update Count Manually:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: editController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Enter new number"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      int newVal = int.tryParse(editController.text) ?? count;
                      // Update specific variables based on title
                      if (title.contains("Total")) totalTickets = newVal;
                      if (title.contains("Pending")) pendingTickets = newVal;
                      if (title.contains("Fixed")) fixedTickets = newVal;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---
  Widget _statBox(String label, String value, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border(top: BorderSide(color: color, width: 4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactTile(IconData icon, String title, String sub) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: primaryGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _ticketItem(String id, String msg, String status) {
    return ListTile(
      leading: Text(id, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      title: Text(msg, style: const TextStyle(fontSize: 14)),
      trailing: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
        child: Text(status, style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 10),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
  );
}