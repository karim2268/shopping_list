import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_list.dart';
import 'dart:convert';

class DataService {
  static const _key = 'shoppingLists';

  static Future<List<ShoppingList>> loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final listsJson = prefs.getStringList(_key) ?? [];
    return listsJson
        .map((jsonString) => ShoppingList.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  static Future<void> saveLists(List<ShoppingList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final listsJson = lists.map((list) => jsonEncode(list.toJson())).toList();
    await prefs.setStringList(_key, listsJson);
  }

  static Future<void> updateList(ShoppingList updatedList) async {
    final lists = await loadLists();
    final index = lists.indexWhere((list) => list.id == updatedList.id);
    if (index != -1) {
      lists[index] = updatedList;
      await saveLists(lists);
    }
  }

  static Future<void> deleteList(String listId) async {
    final lists = await loadLists();
    lists.removeWhere((list) => list.id == listId);
    await saveLists(lists);
  }
}
