import 'package:flutter/material.dart';
import '../models/shopping_item.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final Function(double) onPriceChanged;
  final Function(bool?) onPurchasedChanged;
  final VoidCallback onDelete;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onPriceChanged,
    required this.onPurchasedChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: item.isPurchased,
              onChanged: onPurchasedChanged,
            ),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  decoration: item.isPurchased
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                enabled: !item.isPurchased,
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController()
                  ..text = item.price > 0 ? item.price.toStringAsFixed(2) : '',
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0;
                  onPriceChanged(price);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
