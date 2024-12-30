import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:task_champ/flutter_flow/flutter_flow_theme.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _currentToken;

  NotificationService._internal();

  Future<void> init() async {
    try {
      print('🌟 [NotificationService] Initializing Notifications');

      // Request notification permissions (cross-platform)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print(
          '🌟 [NotificationService] Notification Permission Status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('🌟 [NotificationService] Notification permissions granted');

        // Get and log the FCM token
        _currentToken = await getFCMToken();

        // Configure message handlers
        FirebaseMessaging.onMessage.listen(
          (message) {
            print('🌟 [NotificationService] Foreground Message Received');
            print('🌟 Title: ${message.notification?.title}');
            print('🌟 Body: ${message.notification?.body}');
            print('🌟 Data: ${message.data}');

            // Show a dialog or local notification
            if (message.notification != null) {
              _showNotificationDialog(
                title: message.notification!.title ?? 'Notification',
                body: message.notification!.body ?? '',
              );
            }
          },
          onError: (error) {
            print('🌟 [NotificationService] Foreground Message Error: $error');
          },
        );

        FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
            print('🌟 [NotificationService] Message Opened App');
            print('🌟 Title: ${message.notification?.title}');
            _handleBackgroundMessage(message);
          },
          onError: (error) {
            print('🌟 [NotificationService] Background Message Error: $error');
          },
        );

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          print('🌟 [NotificationService] FCM Token refreshed: $newToken');
        });

        // Send a welcome notification
        print(
            '🌟 [NotificationService] Attempting to send welcome notification');
        await _sendWelcomeNotification();
      } else {
        print('🌟 [NotificationService] Notification permissions not granted');
      }
    } catch (e) {
      print('🌟 [NotificationService] Initialization Error: $e');
    }
  }

  Future<void> _sendWelcomeNotification() async {
    print('🌟 [NotificationService] Sending Welcome Notification');
    try {
      // Get current time
      final now = DateTime.now();
      String greeting;

      if (now.hour < 12) {
        greeting = 'Good Morning';
      } else if (now.hour < 17) {
        greeting = 'Good Afternoon';
      } else {
        greeting = 'Good Evening';
      }

      // List of motivational messages
      final motivationalMessages = [
        'Ready to conquer your tasks today?',
        'Let\'s make today amazing!',
        'Your productivity starts now!',
        'Time to crush your goals!',
        'Every task is a step towards success!',
      ];

      // Randomly select a motivational message
      final randomMessage = motivationalMessages[
          DateTime.now().millisecondsSinceEpoch % motivationalMessages.length];

      print('🌟 [NotificationService] Notification Details: '
          'Title: $greeting 🌟, '
          'Body: $randomMessage');

      // Send the welcome notification
      await sendTaskNotification(
        title: '$greeting! 🌟',
        body: randomMessage,
        data: {
          'type': 'welcome',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('🌟 [NotificationService] Welcome Notification Sent Successfully');
    } catch (e) {
      print('🌟 [NotificationService] Welcome Notification Error: $e');
    }
  }

  Future<void> triggerWelcomeNotification() async {
    print('🌟 [NotificationService] Manually Triggering Welcome Notification');
    try {
      // Get current time
      final now = DateTime.now();
      String greeting;

      if (now.hour < 12) {
        greeting = 'Good Morning';
      } else if (now.hour < 17) {
        greeting = 'Good Afternoon';
      } else {
        greeting = 'Good Evening';
      }

      // List of motivational messages
      final motivationalMessages = [
        'Ready to conquer your tasks today?',
        'Let\'s make today amazing!',
        'Your productivity starts now!',
        'Time to crush your goals!',
        'Every task is a step towards success!',
      ];

      // Randomly select a motivational message
      final randomMessage = motivationalMessages[
          DateTime.now().millisecondsSinceEpoch % motivationalMessages.length];

      print('🌟 [NotificationService] Manual Notification Details: '
          'Title: $greeting 🌟, '
          'Body: $randomMessage');

      // Send the welcome notification
      await sendTaskNotification(
        title: '$greeting! 🌟',
        body: randomMessage,
        data: {
          'type': 'manual_welcome',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print(
          '🌟 [NotificationService] Manual Welcome Notification Sent Successfully');
    } catch (e) {
      print('🌟 [NotificationService] Manual Welcome Notification Error: $e');
    }
  }

  Future<void> sendTaskNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('🌟 [NotificationService] Preparing to send task notification');

      // Ensure we have a token
      _currentToken ??= await _firebaseMessaging.getToken();

      if (_currentToken == null) {
        print(
            '🌟 [NotificationService] No FCM token available for sending notification');
        return;
      }

      // Prepare notification message
      final message = RemoteMessage(
        notification: RemoteNotification(
          title: title,
          body: body,
        ),
        data: data ?? {},
      );

      // Send the message
      try {
        await FirebaseMessaging.instance.sendMessage(
          to: _currentToken,
          data: {
            'title': title,
            'body': body,
            ...?data,
          },
        );
        print('🌟 [NotificationService] Notification sent successfully');
      } catch (sendError) {
        print(
            '🌟 [NotificationService] Error sending notification: $sendError');
      }
    } catch (e) {
      print('🌟 [NotificationService] Notification sending error: $e');
    }
  }

  Future<String?> getFCMToken() async {
    try {
      // Get the current FCM token
      final token = await _firebaseMessaging.getToken();

      // Log the token
      print('🌟 [NotificationService] FCM Token: $token');

      // Optional: Show token in a dialog (be cautious about showing tokens in production)
      _showTokenDialog(token);

      return token;
    } catch (e) {
      print('🛑 [NotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  void _showTokenDialog(String? token) {
    if (token == null) return;

    // Check if we have a valid navigator context
    final context = NavigatorKey.navigatorKey.currentContext;
    if (context == null) {
      print(
          '🌟 [NotificationService] No valid navigator context for token dialog');
      return;
    }

    // Use a post-frame callback to ensure the dialog is shown after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              'FCM Token',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
            ),
            content: SingleChildScrollView(
              child: Text(
                token,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Outfit',
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Copy',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Outfit',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Dismiss',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Outfit',
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
              ),
            ],
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } catch (e) {
        print('🌟 [NotificationService] Error showing token dialog: $e');
      }
    });
  }

  // Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Ensure Firebase is initialized in the background
    await Firebase.initializeApp();

    print('🌟 [NotificationService] Background message received');
    print('🌟 Title: ${message.notification?.title}');
    print('🌟 Body: ${message.notification?.body}');
    print('🌟 Data: ${message.data}');
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print(
        '🌟 [NotificationService] Handling background message when app is opened');
    print('🌟 Title: ${message.notification?.title}');
    print('🌟 Body: ${message.notification?.body}');
    print('🌟 Data: ${message.data}');

    // You can add navigation logic here based on the message data
    // For example:
    // if (message.data['type'] == 'task_reminder') {
    //   Navigator.of(NavigatorKey.navigatorKey.currentContext!).pushNamed('/tasks');
    // }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      _showNotificationDialog(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
      );
    }
  }

  // Show notification dialog for foreground messages
  void _showNotificationDialog({
    required String title,
    required String body,
  }) {
    // Check if we have a valid navigator context
    if (NavigatorKey.navigatorKey.currentContext == null) {
      print('🌟 [NotificationService] No valid navigator context for dialog');
      return;
    }

    showDialog(
      context: NavigatorKey.navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: FlutterFlowTheme.of(context).titleLarge.override(
                fontFamily: 'Outfit',
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
        content: Text(
          body,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Outfit',
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Dismiss',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).primary,
                  ),
            ),
          ),
        ],
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $topic');
    }
  }

  // Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $topic');
    }
  }
}

// Global navigator key to show dialogs from anywhere
class NavigatorKey {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
