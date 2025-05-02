class Task {
  int? id; // Nullable çünkü veritabanı tarafından otomatik olarak atanacak
  String date;
  String title;
  int categoryId;

  Task({
    this.id, // id artık opsiyonel (nullable) çünkü veritabanı tarafından atanacak
    required this.title,
    required this.date,
    required this.categoryId,
  });

  // Veritabanı için görevi haritaya dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id nullable, veritabanı tarafından otomatik atanacak
      'date': date,
      'title': title,
      'category_id': categoryId,
    };
  }

  // Haritadan görev oluşturma
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'], // id veritabanından alınacak
      date: map['date'],
      title: map['title'],
      categoryId: map['category_id'],
    );
  }
}
