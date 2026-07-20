import 'package:flutter/material.dart';

class UserRequestHandling extends StatefulWidget {
  const UserRequestHandling({super.key});

  @override
  State<UserRequestHandling> createState() => _UserRequestHandlingState();
}

class _UserRequestHandlingState extends State<UserRequestHandling> {
  String selectedTab = "PENDING";
  List<Map<String, dynamic>> requests = [
    {
      "id": "REQ-101",
      "name": "Ahmed Raza",
      "role": "Wheat Specialist / گندم کا ماہر",
      "location": "Gujranwala",
      "status": "PENDING",
    },
    {
      "id": "REQ-102",
      "name": "Zahid Ali",
      "role": "Soil Scientist / ماہر مٹی",
      "location": "Sialkot",
      "status": "VERIFIED",
    },
    {
      "id": "REQ-103",
      "name": "Ali Khan",
      "role": "Pesticide Expert / ماہر ادویات",
      "location": "Lahore",
      "status": "REJECTED",
    },
    {
      "id": "REQ-104",
      "name": "Muhammad Bilal",
      "role": "Rice Expert / چاول کا ماہر",
      "location": "Sheikhupura",
      "status": "PENDING",
    },
    {
      "id": "REQ-105",
      "name": "Hassan",
      "role": "Plant Pathologist / پودوں کا ڈاکٹر",
      "location": "Faisalabad",
      "status": "PENDING",
    },
    {
      "id": "REQ-106",
      "name": "Usman",
      "role": "Livestock Expert / ماہر مویشی",
      "location": "Multan",
      "status": "VERIFIED",
    },
    {
      "id": "REQ-107",
      "name": "Arslan",
      "role": "Organic Farming Expert / نامیاتی کاشتکاری",
      "location": "Okara",
      "status": "PENDING",
    },
  ];

  void handleAction(int indexInFiltered, String action) {
    var filteredList = requests.where((r) => r['status'] == selectedTab).toList();
    var item = filteredList[indexInFiltered];
    int originalIndex = requests.indexOf(item);

    setState(() {
      requests[originalIndex]['status'] = action == "approve" ? "VERIFIED" : "REJECTED";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action == "approve" ? "Approved Successfully!" : "Rejected!"),
        backgroundColor: action == "approve" ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B4332);

    List<Map<String, dynamic>> filteredRequests = requests
        .where((req) => req['status'] == selectedTab)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "USER REQUESTS / درخواستیں",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab("PENDING", primaryGreen),
                _buildTab("VERIFIED", primaryGreen),
                _buildTab("REJECTED", primaryGreen),
              ],
            ),
          ),
          Expanded(
            child: filteredRequests.isEmpty
                ? Center(child: Text("No $selectedTab requests found / کوئی ڈیٹا نہیں ہے"))
                : ListView.builder(
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                var req = filteredRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: primaryGreen.withOpacity(0.1),
                            child: const Icon(Icons.person, color: primaryGreen, size: 30),
                          ),
                          title: Text(req['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(req['role']),
                          trailing: _statusChip(req['status']),
                        ),
                        const Divider(),
                        if (selectedTab == "PENDING")
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => handleAction(index, "approve"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text("Approve / منظور", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => handleAction(index, "reject"),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                  child: const Text("Reject / مسترد", style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              selectedTab == "VERIFIED" ? "User is Verified" : "User was Rejected",
                              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, Color color) {
    bool isActive = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(height: 3, width: 40, color: color, margin: const EdgeInsets.only(top: 4)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color chipColor = status == "VERIFIED" ? Colors.green : (status == "REJECTED" ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: chipColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: chipColor, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}