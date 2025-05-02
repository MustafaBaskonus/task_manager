import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Takvim için
import '../../helpers/database_helper.dart';
import '../../models/task.dart';
import '../task/task_add_page.dart'; // Task modelini import edin

class CategoryPage extends StatefulWidget {
  final String title; // Kategori adı
  final int? categoryId; // Kategori ismi (veya ID)
  final IconData categoryIcon; // Kategori ikonu

  CategoryPage({
    required this.title,
    required this.categoryId,
    required this.categoryIcon,
  });

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late DateTime _selectedDay;
  late ValueNotifier<List<Task>> _selectedTasks;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedTasks = ValueNotifier([]);
    _loadTasks(); // İlk yükleme
  }

  // Kategorilere ait görevleri yükleyen fonksiyon
  Future _loadTasks() async {
    final dbHelper = DatabaseHelper.instance;
    final fetchedTasks =
        await dbHelper.fetchTasksByCategoryId(widget.categoryId ?? 0);
    setState(() {
      _selectedTasks.value = fetchedTasks;
    });
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    super.dispose();
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _selectedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });
      },
      eventLoader: (day) {
        return _selectedTasks.value
            .where((task) => task.date == day.toString())
            .toList();
      },
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Kategori adı
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCalendar(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(
                      categoryName: widget.title,
                      categoryIcon: widget.categoryIcon,
                      categoryId: widget.categoryId ?? 0,
                    ),
                  ),
                );

                if (result != null) {
                  _loadTasks(); // Yeni görev eklendikten sonra listeyi güncelle
                }
              },
              child: const Text('Görev Ekle'),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Task>>(
              valueListenable: _selectedTasks,
              builder: (context, tasks, _) {
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0), // Dış boşluk
                      padding: const EdgeInsets.all(16.0), // İç boşluk
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Hafif gri arka plan
                        borderRadius:
                            BorderRadius.circular(8.0), // Köşe yuvarlama
                        border: Border.all(
                          color: Colors.grey[400]!, // Kenar rengi
                          width: 1.0, // Kenar genişliği
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Görev Başlığı
                              Text(
                                task.title,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  // Güncelle Butonu
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.green),
                                    onPressed: () async {
                                      // Güncelle sayfasına git
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddTaskPage(
                                            categoryName: widget.title,
                                            categoryIcon: widget.categoryIcon,
                                            categoryId: widget.categoryId ?? 0,
                                            task:
                                                task, // Task bilgileri gönderiliyor
                                          ),
                                        ),
                                      );

                                      if (result != null) {
                                        _loadTasks(); // Güncelleme sonrası listeyi yenile
                                      }
                                    },
                                  ),
                                  // Sil Butonu
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final dbHelper = DatabaseHelper.instance;
                                      // Null kontrolü
                                      if (task.id != null) {
                                        await dbHelper.deleteTask(
                                            task.id!); // Veritabanından sil
                                        _loadTasks(); // Silme sonrası listeyi yenile
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 8.0), // Başlık ile tarih arası boşluk
                          // Görev Tarihi
                          Text(
                            task.date,
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
