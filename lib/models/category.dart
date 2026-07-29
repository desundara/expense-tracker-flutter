enum CategoryType { income, expense }

class Category {
  final int? id;
  final String name;
  final String icon; // icon identifier, e.g. 'utensils', 'car', 'bag'
  final CategoryType type;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type == CategoryType.income ? 'income' : 'expense',
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      type: map['type'] == 'income' ? CategoryType.income : CategoryType.expense,
    );
  }
}