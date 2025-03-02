import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mobile_app/Screens/notification_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NotificationService() {
    initializeNotifications();
  }

  // Handle notification tap
  Future<void> onNotificationSelected(BuildContext context, String? payload, String userId) async {
    if (payload != null) {
      print("Notification tapped! Payload: $payload");

      // Navigate to NotificationScreen when tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationScreen(userId: userId)),
      );
    }
  }
  
  // Define the getUserId method
  Future<String> getUserId(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc['userId'];
  }

  Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: darwinSettings);

    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        String userId = await getUserId(response.payload!);
        onNotificationSelected(navigatorKey.currentContext!, response.payload, userId);
      },
    );

    if (kDebugMode) {
      print("🎉 Notifications initialized successfully!");
    }
  }

  // Define notification details (with larger text for better readability)
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'meal_channel_id',
        'Meal Reminders',
        channelDescription: 'Notification channel for meal reminders',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''), // Allow big text style for longer messages
      ),
    );
  }

  // Show a simple notification
  Future<void> showNotification({
    int id = 0,
    String? category,
    String? mealName,
    required String formattedDate,
  }) async {
    String message = "You plan your $category meal: $mealName, for $formattedDate!"; // Ensure proper formatting
    return notificationsPlugin.show(
      id,
      category,
      message,
      notificationDetails(),
      payload: 'notification_payload',
    );
  }

  // Schedule a notification at a specific time
  Future<void> scheduleNotification({
    int id = 1,
    required String category,
    required String mealName,
    required DateTime scheduledTime,
    required String formattedDate,
  }) async {
    if (kDebugMode) {
      print('Scheduling notification: $category - $mealName at $scheduledTime');
    }

    showNotification(category: category, mealName: mealName, formattedDate: formattedDate);

    await notificationsPlugin.zonedSchedule(
      id,
      category,
      mealName,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      print('Notification saved and scheduled for $scheduledTime');
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancelAll();
  }

  // Save notification to Firestore and schedule local notification
  Future<void> saveNotification(String userId, String category, String mealName, String Date) async {
    try {
      Duration notificationDuration;

      switch (category.toLowerCase()) {
        case 'breakfast':
          notificationDuration = Duration(hours: 6);
          break;
        case 'lunch':
          notificationDuration = Duration(hours: 12);
          break;
        case 'dinner':
          notificationDuration = Duration(hours: 18);
          break;
        case 'salad':
          notificationDuration = Duration(hours: 5);
          break;
        case 'soup':
          notificationDuration = Duration(hours: 7);
          break;
        case 'dessert':
          notificationDuration = Duration(hours: 9);
          break;
        default:
          notificationDuration = Duration(seconds: 10);
          break;
      }

      DateTime mealTime = DateTime.now().add(notificationDuration);

      scheduleNotification(
        category: category,
        mealName: mealName,
        scheduledTime: mealTime,
        formattedDate: Date,
      );

      if (kDebugMode) {
        print('Saved notification for $mealName at $mealTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notification: $e');
      }
    }
  }
}
