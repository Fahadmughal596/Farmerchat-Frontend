import 'package:flutter/material.dart';

import 'package:dashboard_screen/models/notification_model.dart';
import 'package:dashboard_screen/services/api_services.dart';
import 'package:dashboard_screen/utility/app_constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService api = ApiService();
  late Future<List<NotificationModel>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = api.getNotifications();
  }

  Future<void> _reload() async {
    setState(() {
      notifications = api.getNotifications();
    });
    await notifications;
  }

  Color _priorityColor(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('critical')) return Colors.red;
    if (p.contains('high')) return Colors.orange;
    return AppConstants.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryGreen));
          }

          final list = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _reload,
            child: list.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 180),
                      Icon(Icons.notifications_none, size: 58, color: Colors.grey),
                      SizedBox(height: 12),
                      Center(child: Text('No notifications yet')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final color = _priorityColor(item.priority);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withOpacity(.18))),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(Icons.notifications_active, color: color)),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item.message),
                              const SizedBox(height: 6),
                              Text(item.createdAt, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          trailing: item.isRead
                              ? null
                              : TextButton(
                                  child: const Text('Read'),
                                  onPressed: () async {
                                    await api.markNotificationRead(item.id);
                                    await _reload();
                                  },
                                ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
