import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Do nothing
    debugPrint('Notification service initialized (no-op)');
  }

  Future<void> showTaskNotification({
    int? id,
    required String title,
    required String body,
    DateTime? scheduledTime,
  }) async {
    // Do nothing, just log
    debugPrint('Notification would have been shown: $title - $body');
  }

  Future<void> cancelNotification(int id) async {
    // Do nothing
    debugPrint('Cancel notification called (no-op)');
  }

  Future<void> cancelAllNotifications() async {
    // Do nothing
    debugPrint('Cancel all notifications called (no-op)');
  }
}
