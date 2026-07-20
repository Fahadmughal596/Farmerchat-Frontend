import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/api_services.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<NotificationModel> _notifications = [];

  int _unreadCount = 0;

  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _unreadCount;

  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    _notifications = await _api.getNotifications();

    _unreadCount = await _api.getUnreadCount();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadNotifications();
  }

  Future<void> markAsRead(int id) async {
    final success = await _api.markNotificationRead(id);

    if (success) {
      final index = _notifications.indexWhere(
        (e) => e.id == id,
      );

      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          notificationType:
              _notifications[index].notificationType,
          priority: _notifications[index].priority,
          action: _notifications[index].action,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
      }

      _unreadCount =
          _notifications.where((e) => !e.isRead).length;

      notifyListeners();
    }
  }
}