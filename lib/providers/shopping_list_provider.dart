// providers/shopping_list_provider.dart
import 'package:flutter/material.dart';

class ShoppingListProvider with ChangeNotifier {
  final List<String> _shoppingList = [];

  List<String> get shoppingList => _shoppingList;

  void addItems(List<String> items) {
   
    _shoppingList.addAll(items);
    notifyListeners();
  }

  void removeItem(String item) {
    _shoppingList.remove(item);
    notifyListeners();
  }
}
