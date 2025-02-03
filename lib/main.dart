import 'package:flutter/material.dart';
import 'screens/list_selection_screen.dart';

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
      home: const ListSelectionScreen(),
    );
  }
}
