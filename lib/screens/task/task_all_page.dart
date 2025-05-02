import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../models/task.dart'; // Task modelini import edin

class AllTaskPage extends StatefulWidget {
  @override
  _AllTaskPageState createState() => _AllTaskPageState();
}

class _AllTaskPageState extends State<AllTaskPage> {
  late Future<List<Task>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = _loadTasks(); // Görevleri yükle
  }

  // Task'ları yükleyen fonksiyon
  Future<List<Task>> _loadTasks() async {
    final dbHelper = DatabaseHelper.instance;
    final taskList =
        await dbHelper.fetchTasks(); // Tüm görevleri veritabanından al
    return taskList;
  }

  // Görev silme fonksiyonu
  Future<void> _deleteTask(int taskId) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteTask(taskId); // Görevi veritabanından sil
    setState(() {
      tasks = _loadTasks(); // Listeyi güncelle
    });
  }

  // Görev düzenleme fonksiyonu
  void _editTask(Task task) {
    // Edit sayfasına yönlendirme kodu buraya eklenebilir
    // Örnek: Navigator.push(...)
    // Burada task'ı düzenlemek için ilgili sayfaya yönlendirebilirsiniz
    print("Görev düzenlenecek: ${task.title}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tüm Görevler"), // Başlık
      ),
      body: FutureBuilder<List<Task>>(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Yükleniyor göstergesi
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu!'));
          }

          final taskList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: taskList.length,
            itemBuilder: (context, index) {
              final task = taskList[index];

              return Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0), // Dış boşluk
                padding: const EdgeInsets.all(16.0), // İç boşluk
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Hafif gri arka plan
                  borderRadius: BorderRadius.circular(8.0), // Köşe yuvarlama
                  border: Border.all(
                    color: Colors.grey[400]!, // Kenar rengi
                    width: 1.0, // Kenar genişliği
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                        height: 8.0), // Başlık ile tarih arası boşluk
                    Text(
                      task.date,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _editTask(task), // Görev düzenleme
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Null kontrolü yapalım
                            if (task.id != null) {
                              // Null değilse, `int` olarak geçirebiliriz
                              _deleteTask(
                                  task.id!); // `!` kullanarak int'e dönüştürme
                            } else {
                              // Hata durumunu burada yönetebilirsiniz
                              print("ID boş");
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
