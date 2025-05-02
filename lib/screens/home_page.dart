import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/category.dart';
import '../models/task.dart';
import 'category/category_card.dart';
import 'category/category_page.dart';
import 'task/task_all_page.dart';
import 'task/task_mytask_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<HomePage> {
  List<Category> categories = [];
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Kategorileri yüklemek için çağırıyoruz
    _loadTasks(); // Görevleri yüklemek için çağırıyoruz
  }

  void _loadCategories() async {
    final dbHelper = DatabaseHelper.instance;
    final fetchedCategories = await dbHelper.fetchCategories();

    if (fetchedCategories.isEmpty) {
      // Kategoriler boşsa, varsayılan kategorileri ekle
      await _addDefaultCategories();
      // Kategorileri tekrar yükle
      _loadCategories();
    }

    setState(() {
      categories = fetchedCategories;
    });
  }

  Future _addDefaultCategories() async {
    final dbHelper = DatabaseHelper.instance;

    // 3 adet kategori ekleyelim
    final category1 = Category(name: 'Dersler', icon: 'book');
    final category2 = Category(name: 'İlaç', icon: 'medication');
    final category3 = Category(name: 'Uyku', icon: 'bedtime');

    await dbHelper.insertCategory(category1);
    await dbHelper.insertCategory(category2);
    await dbHelper.insertCategory(category3);
  }

  // Görevleri yükle
  Future _loadTasks() async {
    final dbHelper = DatabaseHelper.instance;
    final fetchedTasks = await dbHelper.fetchTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  // Yeni kategori ekle
  Future _addCategory() async {
    final category = Category(name: 'Work', icon: 'work_icon.png');
    await DatabaseHelper.instance.insertCategory(category);
    _loadCategories(); // Kategorileri yeniden yükle
  }

  // Icon için bir harita oluşturuyoruz
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'book':
        return Icons.book;
      case 'medication':
        return Icons.medication;
      case 'bedtime':
        return Icons.bedtime;
      case 'work_icon.png':
        return Icons.work;
      default:
        return Icons.category; // Varsayılan ikon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Kategorilerin bulunduğu GridView
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.length +
                        1, // Tasklarım kartını eklemek için 1 artırıyoruz
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // İlk kart Tasklarım
                        return TasklarimCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AllTaskPage(), // AllTaskPage'i doğru şekilde import edin
                              ),
                            );
                          },
                        );
                      }

                      final category = categories[index - 1];
                      final categoryIcon = _getCategoryIcon(category.icon);

                      return CategoryCard(
                        title: category.name,
                        icon: categoryIcon,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryPage(
                              title: category.name,
                              categoryId: category.id,
                              categoryIcon: categoryIcon,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Görevlerin bulunduğu ListView
                  ListView.builder(
                    shrinkWrap:
                        true, // ListView'in ekranın tamamını kaplamaması için
                    physics:
                        const NeverScrollableScrollPhysics(), // ListView'in kaydırılmaması için
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.date),
                        onTap: () {
                          // Task detaylarına gitmek için navigasyon ekleyebilirsiniz
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Butonlar sabit olarak en altta olacak
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text('Kategori Ekle'),
                ),
                ElevatedButton(
                  onPressed: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskPage(
                          category: category.name, // Kategoriyi ekliyoruz
                          categoryIcon:
                              categoryIcon, // Kategori ikonunu ekliyoruz
                        ),
                      ),
                    );*/
                  },
                  child: const Text('Görev Ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
