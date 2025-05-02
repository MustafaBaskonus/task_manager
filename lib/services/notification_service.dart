import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Bildirimleri zamanlamak için kullanılan metod
  static Future<void> showScheduledNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    var androidDetails = const AndroidNotificationDetails(
      'your_channel_id', // Kanal kimliği
      'your_channel_name', // Kanal adı
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    // Bildirim zamanlamayı zonedSchedule ile yapıyoruz
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local), // TZDateTime kullanımı
      platformDetails,
      //androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // androidScheduleMode parametresi
    );
  }

  // Bildirim başlatma
  static Future<void> init() async {
    tzdata.initializeTimeZones(); // Zaman dilimlerini başlat

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Uygulama simgesi

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Bildirim zamanlamak
  static Future<void> scheduleNotification(DateTime scheduledTime) async {
    // TZDateTime'e dönüştürme
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Bildirimi zamanla
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled Task',
      'This is your task reminder!',
      scheduledDate, // TZDateTime kullanıldı
      platformChannelSpecifics,
      //androidAllowWhileIdle: true, // Bu parametreyi ekledik
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // androidScheduleMode parametresi
    );
  }
}
