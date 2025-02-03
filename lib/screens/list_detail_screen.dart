import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';
import '../services/data_service.dart';
import '../widgets/shopping_item_card.dart';

class ListDetailScreen extends StatefulWidget {
  final ShoppingList list;

  const ListDetailScreen({super.key, required this.list});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  late ShoppingList _currentList;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _currentList = widget.list;
  }

  void _addItem(String name) async {
    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _currentList.items.add(newItem);
    await _saveList();
    setState(() {});
  }

  void _deleteItem(String id) async {
    _currentList.items.removeWhere((item) => item.id == id);
    await _saveList();
    setState(() {});
  }

  Future<void> _saveList() async {
    await DataService.updateList(_currentList);
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String itemName = '';
        return AlertDialog(
          title: const Text('Ajouter un article'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'article',
              hintText: 'Lait, Pain, Œufs...',
            ),
            onChanged: (value) => itemName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (itemName.isNotEmpty) {
                  _addItem(itemName);
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentList.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Total: ${_currencyFormat.format(_currentList.totalPrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _currentList.items.length,
        itemBuilder: (context, index) {
          final item = _currentList.items[index];
          return ShoppingItemCard(
            item: item,
            onPriceChanged: (price) async {
              item.price = price;
              await _saveList();
              setState(() {});
            },
            onPurchasedChanged: (value) async {
              item.isPurchased = value ?? false;
              await _saveList();
              setState(() {});
            },
            onDelete: () => _deleteItem(item.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Ajouter un article',
        child: const Icon(Icons.add),
      ),
    );
  }
}
