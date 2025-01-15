import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SavedFoodProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _savedRecipes = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> get savedRecipes => _savedRecipes;

  // Fetch saved recipes from Firestore
  Future<void> fetchSavedRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_recipes')
          .get();

      // Clear the current saved recipes and load new ones
      _savedRecipes.clear();
      
      for (var doc in snapshot.docs) {
        _savedRecipes.add(doc.data() as Map<String, dynamic>);
      }
      
      notifyListeners(); // Notify listeners after data is fetched
    } catch (e) {
      print("Error fetching saved recipes: $e");
      throw Exception("Error fetching saved recipes");
    }
  }

  // Add recipe
  void addRecipe(Map<String, dynamic> recipe) {
    _savedRecipes.add(recipe);
    notifyListeners();
  }

  // Remove recipe
  void removeRecipe(Map<String, dynamic> recipe) {
    _savedRecipes.remove(recipe);
    notifyListeners();
  }

  void removeRecipes(Map<String, dynamic> recipe) {
    _savedRecipes.removeWhere((savedRecipe) => savedRecipe['id'] == recipe['id']);
    notifyListeners();
  }
}
