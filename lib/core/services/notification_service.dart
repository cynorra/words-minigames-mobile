import 'dart:io';
import 'dart:ui' as ui;
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

  /// Get current device/app language code (e.g., 'en', 'tr', 'es')
  String _getLanguageCode() {
    try {
      final code = ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      return code;
    } catch (_) {
      return 'en';
    }
  }

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

      // Schedule smart multilingual engagement notifications
      await scheduleEngagementNotifications();
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  /// Schedule notifications to drive daily retention and engagement
  Future<void> scheduleEngagementNotifications() async {
    if (!_isInitialized) return;

    try {
      final lang = _getLanguageCode();
      final content = _getNotificationContent(lang);

      // 1. Notification: 4 Hours later (Quick break)
      await _scheduleRelativeNotification(
        id: 101,
        title: content.breakTitle,
        body: content.breakBody,
        delay: const Duration(hours: 4),
      );

      // 2. Notification: Daily 20:00 (Daily Brain Workout)
      await _scheduleDailyEveningNotification(
        title: content.dailyTitle,
        body: content.dailyBody,
      );

      // 3. Notification: 2 Days later (Re-engagement / Inactivity)
      await _scheduleRelativeNotification(
        id: 103,
        title: content.inactivityTitle,
        body: content.inactivityBody,
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
  Future<void> _scheduleDailyEveningNotification({
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 20:00 (8 PM)
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
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Multi-language notification texts
  _NotificationText _getNotificationContent(String lang) {
    switch (lang) {
      case 'tr':
        return const _NotificationText(
          breakTitle: 'Hızlı bir mola ver! ⚡',
          breakBody: '2 dakikalık bir mini oyun zihnini tazelemeye yeter! Skorunu yükseltmeye hazır mısın?',
          dailyTitle: 'Günün Beyin Egzersizi! 🧠',
          dailyBody: 'Bugün zihnini test ettin mi? Günün rekorunu kırmak için hemen bir oyun seç!',
          inactivityTitle: 'Liderlik tablosu seni bekliyor! 🏆',
          inactivityBody: 'Yeni rekorlar kırıldı! Zirvedeki yerini korumak için hemen geri dön.',
        );

      case 'es':
        return const _NotificationText(
          breakTitle: '¡Tómate un descanso! ⚡',
          breakBody: '¡2 minutos de minijuegos son suficientes para despejar tu mente! ¿Listo para superar tu récord?',
          dailyTitle: '¡Entrenamiento cerebral diario! 🧠',
          dailyBody: '¿Has desafiado tu mente hoy? ¡Elige un juego y rompe el récord!',
          inactivityTitle: '¡La tabla de clasificación te espera! 🏆',
          inactivityBody: '¡Se establecieron nuevos récords! Vuelve y defiende tu lugar en la cima.',
        );

      case 'pt':
        return const _NotificationText(
          breakTitle: 'Faça uma pausa rápida! ⚡',
          breakBody: '2 minutos de minijogos são suficientes para renovar sua mente! Pronto para bater seu recorde?',
          dailyTitle: 'Treino Cerebral Diário! 🧠',
          dailyBody: 'Já desafiou sua mente hoje? Escolha um jogo e quebre o recorde!',
          inactivityTitle: 'O placar de líderes espera por você! 🏆',
          inactivityBody: 'Novos recordes foram batidos! Volte e defenda seu lugar no topo.',
        );

      case 'de':
        return const _NotificationText(
          breakTitle: 'Gönn dir eine kurze Pause! ⚡',
          breakBody: 'Ein 2-Minuten-Denkspiel reicht aus! Bereit, deinen Highscore zu knacken?',
          dailyTitle: 'Tägliches Gehirntraining! 🧠',
          dailyBody: 'Hast du deinen Verstand heute schon gefordert? Knacke jetzt den Rekord!',
          inactivityTitle: 'Die Bestenliste wartet! 🏆',
          inactivityBody: 'Neue Rekorde wurden aufgestellt! Verteidige deinen Platz an der Spitze.',
        );

      case 'fr':
        return const _NotificationText(
          breakTitle: 'Faites une petite pause ! ⚡',
          breakBody: '2 minutes de mini-jeux suffisent pour vous ressourcer ! Prêt à battre votre record ?',
          dailyTitle: 'Entraînement Cérébral Quotidien ! 🧠',
          dailyBody: 'Avez-vous défié votre esprit aujourd\'hui ? Choisissez un jeu et battez le record !',
          inactivityTitle: 'Le classement vous attend ! 🏆',
          inactivityBody: 'De nouveaux records ont été établis ! Revenez défendre votre première place.',
        );

      // Default: English (for all other countries worldwide)
      default:
        return const _NotificationText(
          breakTitle: 'Take a quick break! ⚡',
          breakBody: 'A 2-minute brain workout is all you need to recharge! Ready to beat your high score?',
          dailyTitle: 'Daily Brain Workout! 🧠',
          dailyBody: 'Have you challenged your mind today? Pick a mini game and break today\'s record!',
          inactivityTitle: 'The Leaderboard awaits! 🏆',
          inactivityBody: 'New high scores were set! Come back and defend your crown.',
        );
    }
  }
}

class _NotificationText {
  final String breakTitle;
  final String breakBody;
  final String dailyTitle;
  final String dailyBody;
  final String inactivityTitle;
  final String inactivityBody;

  const _NotificationText({
    required this.breakTitle,
    required this.breakBody,
    required this.dailyTitle,
    required this.dailyBody,
    required this.inactivityTitle,
    required this.inactivityBody,
  });
}
