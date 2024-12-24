class Category {
  final int id;
  final String name;
  final bool isProductive;

  Category({
    required this.id,
    required this.name,
    required this.isProductive,
  });

  // Veritabanından gelen veriyi modele çevirme
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      isProductive: map['isProductive'] == 1,
    );
  }

  // Modeli veritabanına kaydetmek için haritaya çevirme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isProductive': isProductive ? 1 : 0,
    };
  }
}
