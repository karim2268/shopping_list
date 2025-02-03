import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/shopping_item.dart';
import 'services/data_service.dart';
import 'widgets/shopping_item_card.dart';

void main() => runApp(const ShoppingListApp());

class ShoppingListApp extends StatelessWidget {
  const ShoppingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Shopping List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ShoppingListScreen(),
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _items = [];
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    _items = await DataService.loadItems();
    setState(() {});
  }

  double get _totalPrice {
    return _items
        .where((item) => item.isPurchased)
        .fold(0, (sum, item) => sum + item.price);
  }

  void _addItem(String name) async {
    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _items.add(newItem);
    await DataService.saveItems(_items);
    setState(() {});
  }

  void _deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await DataService.saveItems(_items);
    setState(() {});
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
        title: const Text('Liste d\'achats'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Total: ${_currencyFormat.format(_totalPrice)}',
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
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ShoppingItemCard(
            item: item,
            onPriceChanged: (price) async {
              item.price = price;
              await DataService.saveItems(_items);
              setState(() {});
            },
            onPurchasedChanged: (value) async {
              item.isPurchased = value ?? false;
              await DataService.saveItems(_items);
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
