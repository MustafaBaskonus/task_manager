class Category {
  int? id;
  String name;
  String icon;

  Category({
    this.id,
    required this.name,
    required this.icon,
  });

  // Veritabanı için kategoriyi haritaya dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  // Haritadan kategori oluşturma
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
    );
  }
}
