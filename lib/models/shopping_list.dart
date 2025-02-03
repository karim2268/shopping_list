import 'shopping_item.dart';

class ShoppingList {
  String id;
  String name;
  List<ShoppingItem> items;
  DateTime createdAt;

  ShoppingList({
    required this.id,
    required this.name,
    this.items = const [],
    required this.createdAt,
  });

  double get totalPrice => items
      .where((item) => item.isPurchased)
      .fold(0, (sum, item) => sum + item.price);

  int get purchasedCount => items.where((item) => item.isPurchased).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'items': items.map((item) => item.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        id: json['id'],
        name: json['name'],
        items: (json['items'] as List)
            .map((item) => ShoppingItem.fromJson(item))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );
}
