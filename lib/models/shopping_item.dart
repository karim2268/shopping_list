class ShoppingItem {
  String id;
  String name;
  double price;
  bool isPurchased;

  ShoppingItem({
    required this.id,
    required this.name,
    this.price = 0.0,
    this.isPurchased = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'isPurchased': isPurchased,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'].toString(), // Conversion explicite en String
        name: json['name'].toString(),
        price: (json['price'] as num).toDouble(),
        isPurchased: json['isPurchased'] as bool? ?? false,
      );
}
