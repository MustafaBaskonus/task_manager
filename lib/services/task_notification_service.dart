import 'package:task_manager/services/notification_service.dart';

import '../helpers/database_helper.dart';
import '../models/task.dart'; // NotificationService'i import edin

class TaskNotificationService {
  // Veritabanındaki tüm görevleri al
  Future<void> scheduleTaskNotifications() async {
    final dbHelper = DatabaseHelper.instance;
    final List<Task> tasks =
        await dbHelper.fetchTasks(); // Görevleri veritabanından al

    // Her bir görev için bildirim zamanla
    for (var task in tasks) {
      // Görevin tarihini al
      DateTime taskDate =
          DateTime.parse(task.date); // Tarihi DateTime nesnesine çevir

      // Görevin tarihinden 1 gün önceki zamanı hesapla
      DateTime oneDayBefore = taskDate.subtract(Duration(days: 1));

      // Görevin tarihinden 5 dakika önceki zamanı hesapla
      DateTime fiveMinutesBefore = taskDate.subtract(Duration(minutes: 5));

      // Bildirim ID'sini benzersiz yapmak için task.id kullanabilirsiniz
      int notificationIdOneDayBefore =
          task.id ?? 0; // Eğer id null ise 0 kullanılır
      int notificationIdFiveMinutesBefore = task.id != null
          ? task.id! + 1
          : 1; // ID'yi benzersiz yapmak için task.id + 1

      // Bildirimi 1 gün önce gönder
      await NotificationService.showScheduledNotification(
          notificationIdOneDayBefore,
          'Görev Hatırlatıcı',
          'Göreviniz 1 gün sonra yapılacak!',
          oneDayBefore);

      // Bildirimi 5 dakika önce gönder
      await NotificationService.showScheduledNotification(
          notificationIdFiveMinutesBefore,
          'Görev Hatırlatıcı',
          'Göreviniz 5 dakika içinde yapılacak!',
          fiveMinutesBefore);
    }
  }
}
