import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize local notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Request notification permissions for Android 13+
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl?.requestNotificationsPermission();
      }

      _isInitialized = true;

      // Schedule smart engagement notifications
      await scheduleEngagementNotifications();
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  /// Schedule notifications to drive daily retention and engagement
  Future<void> scheduleEngagementNotifications() async {
    if (!_isInitialized) return;

    try {
      // 1. Bildirim: 4 Saat Sonra (Kısa mola hatırlatması)
      await _scheduleRelativeNotification(
        id: 101,
        title: 'Hızlı bir mola ver! ⚡',
        body: '2 dakikalık bir mini oyun zihnini tazelemeye yeter! Skorunu yükseltmeye hazır mısın?',
        delay: const Duration(hours: 4),
      );

      // 2. Bildirim: Her Gün 20:00 (Günün Egzersizi)
      await _scheduleDailyEveningNotification();

      // 3. Bildirim: 2 Gün Sonra (Kullanıcıyı geri çağırma)
      await _scheduleRelativeNotification(
        id: 103,
        title: 'Liderlik tablosu seni bekliyor! 🏆',
        body: 'Yeni rekorlar kırıldı! Zirvedeki yerini korumak için hemen geri dön.',
        delay: const Duration(days: 2),
      );
    } catch (e) {
      debugPrint('Error scheduling engagement notifications: $e');
    }
  }

  /// Schedule a notification after a specific duration
  Future<void> _scheduleRelativeNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'engagement_channel',
        'Daily Reminders & Challenges',
        channelDescription: 'Engagement reminders and brain training challenges',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule daily 20:00 evening notification
  Future<void> _scheduleDailyEveningNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 20:00 (Akşam 8)
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_challenge_channel',
        'Daily Brain Challenge',
        channelDescription: 'Daily 8 PM brain training challenges',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      102,
      'Günün Beyin Egzersizi! 🧠',
      'Bugün zihnini test ettin mi? Günün rekorunu kırmak için hemen bir oyun seç!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Send instant test notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel',
        'Instant Notifications',
        channelDescription: 'Real-time test notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(0, title, body, details);
  }
}
