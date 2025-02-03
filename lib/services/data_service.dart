import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';
import 'dart:convert'; // Ajouter cette importation

class DataService {
  static const _key = 'shoppingItems';

  static Future<List<ShoppingItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getStringList(_key) ?? [];
    return itemsJson
        .map((jsonString) => ShoppingItem.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  static Future<void> saveItems(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, itemsJson);
  }
}
