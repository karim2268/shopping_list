import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shopping_list.dart';
import '../services/data_service.dart';
import 'list_detail_screen.dart';

class ListSelectionScreen extends StatefulWidget {
  const ListSelectionScreen({super.key});

  @override
  State<ListSelectionScreen> createState() => _ListSelectionScreenState();
}

class _ListSelectionScreenState extends State<ListSelectionScreen> {
  late Future<List<ShoppingList>> _listsFuture;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yy HH:mm');

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  void _refreshLists() {
    setState(() {
      _listsFuture = DataService.loadLists();
    });
  }

  void _createNewList() async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle liste'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nom de la liste',
            hintText: 'Courses du weekend...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newList = ShoppingList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result,
        createdAt: DateTime.now(),
      );
      final lists = await DataService.loadLists();
      lists.add(newList);
      await DataService.saveLists(lists);
      _refreshLists();
    }
  }

  void _handleListTap(ShoppingList list) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailScreen(list: list),
      ),
    );
    _refreshLists();
  }

  void _deleteList(ShoppingList list) async {
    await DataService.deleteList(list.id);
    _refreshLists();
  }

  void _renameList(ShoppingList list) async {
    final TextEditingController controller =
        TextEditingController(text: list.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renommer la liste'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final lists = await DataService.loadLists();
      final index = lists.indexWhere((l) => l.id == list.id);
      if (index != -1) {
        lists[index] = list..name = newName;
        await DataService.saveLists(lists);
        _refreshLists();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Listes'),
      ),
      body: FutureBuilder<List<ShoppingList>>(
        future: _listsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final lists = snapshot.data ?? [];
          if (lists.isEmpty) {
            return Center(
              child: Text(
                'Appuyez sur + pour créer\nvotre première liste',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return Dismissible(
                key: Key(list.id),
                background: Container(color: Colors.red),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer la liste ?'),
                      content:
                          Text('Supprimer "${list.name}" définitivement ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) => _deleteList(list),
                child: ListTile(
                  title: Text(list.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Créée le ${_dateFormat.format(list.createdAt)}'),
                      Text(
                        '${list.purchasedCount}/${list.items.length} articles',
                        style: TextStyle(
                          color: list.purchasedCount == list.items.length &&
                                  list.items.isNotEmpty
                              ? Colors.green
                              : null,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    _currencyFormat.format(list.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _handleListTap(list),
                  onLongPress: () => _renameList(list),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewList,
        child: const Icon(Icons.add),
      ),
    );
  }
}
