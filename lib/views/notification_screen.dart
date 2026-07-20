import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/api_services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  final ApiService _api = ApiService();

  List<NotificationModel> notifications = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final data = await _api.getNotifications();

    if (!mounted) return;

    setState(() {
      notifications = data;
      loading = false;
    });
  }

  Future<void> markAsRead(NotificationModel item) async {
    if (!item.isRead) {
      await _api.markNotificationRead(item.id);
    }

    // Navigation based on action will be added next.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadNotifications,
              child: notifications.isEmpty
                  ? const Center(
                      child: Text(
                        "No notifications",
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item =
                            notifications[index];

                        return ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              item.isRead
                                  ? Icons.notifications_none
                                  : Icons.notifications,
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Text(item.message),
                          trailing: !item.isRead
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration:
                                      const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () async {
                            await markAsRead(item);

                            await loadNotifications();
                          },
                        );
                      },
                    ),
            ),
    );
  }
}