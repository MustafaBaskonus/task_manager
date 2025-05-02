import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../models/task.dart';

class AddTaskPage extends StatefulWidget {
  final int categoryId; // Parametre adını değiştirdik
  final String categoryName;
  final IconData categoryIcon;
  final Task? task; // task parametresi ekleniyor

  AddTaskPage({
    required this.categoryId, // Parametre adı uyumlu hale getirildi
    required this.categoryName,
    required this.categoryIcon,
    this.task, // optional parametre olarak task ekleniyor
  });

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate; // Seçilen tarih
  TimeOfDay? _selectedTime; // Seçilen saat

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Görev Ekle - ${widget.categoryName}'), // Kategori adını başlıkta göster
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori ikonu
              Icon(
                widget.categoryIcon,
                size: 50,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              // Görev başlığı inputu
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Görev Adi'),
              ),
              const SizedBox(height: 10),
              // Tarih seçme butonu
              ElevatedButton(
                onPressed: () async {
                  _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
                child: const Text('Tarih Seç'),
              ),
              // Saat seçme butonu
              ElevatedButton(
                onPressed: () async {
                  _selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: const Text('Saat Seç'),
              ),
              const SizedBox(height: 20),
              // Görev kaydet butonu
              // AddTaskPage'de
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isNotEmpty &&
                      _selectedDate != null &&
                      _selectedTime != null) {
                    DateTime taskDateTime = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    // Task modelini oluşturuyoruz
                    Task task = Task(
                      title: _titleController.text,
                      date: taskDateTime.toString(),
                      categoryId:
                          widget.categoryId, // Kategori ID'sini kullanıyoruz
                    );

                    // Veritabanına ekliyoruz
                    await DatabaseHelper.instance.insertTask(task);

                    // Yeni eklenen görevi CategoryPage'e döndürüyoruz
                    Navigator.pop(context, task);
                  } else {
                    // Kullanıcı boş alan bırakmışsa uyarı mesajı
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
                    );
                  }
                },
                child: Text('Görev Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
