import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'services/notification_service.dart';
import 'services/task_notification_service.dart';
import 'package:permission_handler/permission_handler.dart'; // Burada izinleri import edin

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bildirim iznini kontrol et ve al
  await checkPermissions();

  // Bildirim servisini başlat
  await NotificationService.init();

  // Görevler için bildirimleri zamanla
  final taskNotificationService = TaskNotificationService();
  await taskNotificationService.scheduleTaskNotifications();

  runApp(const MyApp());
}

// İzinleri kontrol etme fonksiyonu
Future<void> checkPermissions() async {
  // Bildirim iznini kontrol et
  PermissionStatus status = await Permission.notification.status;

  // Eğer izin verilmemişse, izin iste
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
