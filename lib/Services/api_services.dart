import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Set base URL and API key directly here
  final String _baseUrl = 'https://api.spoonacular.com';
  final String _apiKey = '9ecee3af427949d4b5e9831e0b458576'; // Replace with your actual API key

  // 1. General Recipe Search
  Future<List<dynamic>> fetchRecipes(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'] ?? [];
    } else {
      if (kDebugMode) {
        print('Failed to load recipes: ${response.body}');
      }
      throw Exception('Failed to fetch recipes');
    }
  }

  // 2. Ingredient-Based Recipe Search
  Future<List<dynamic>> fetchRecipesByIngredients(List<String> ingredients) async {
    final ingredientsStr = ingredients.join(',');
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/findByIngredients?ingredients=$ingredientsStr&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch recipes by ingredients');
    }
  }

  // 3. Fetch Recipe Details
  Future<Map<String, dynamic>> fetchRecipeDetails(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/$id/information?apiKey=$_apiKey&includeNutrition=true'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch recipe details');
    }
  }

  // 4. Fetch Random Recipes
  Future<List<dynamic>> fetchRandomRecipes({int number = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recipes/random?number=$number&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          print('Fetched random recipes: $data');
        }

        if (data['recipes'] != null) {
          return data['recipes'];
        } else {
          if (kDebugMode) {
            print('No recipes found in the response.');
          }
          return [];
        }
      } else {
        throw Exception('Failed to fetch random recipes. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred while fetching random recipes: $e');
      }
      return [];
    }
  }

  // 5. Fetch Related Recipes
  Future<List<dynamic>> fetchRelatedRecipes(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/$id/similar?apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch related recipes');
    }
  }

  // 6. Meal Planner (Example: Get a meal plan for a day)
  Future<Map<String, dynamic>> fetchMealPlan({String diet = "any"}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mealplanner/generate?timeFrame=day&diet=$diet&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate meal plan');
    }
  }

  // Fetch recipes based on the selected category
  Future<List<dynamic>> fetchRecipesByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes?category=$category&apiKey=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['recipes'];
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // 7. Shopping List from Ingredients
  Future<Map<String, dynamic>> createShoppingList(List<String> ingredients) async {
    return {'shoppingList': ingredients};
  }

  // 8. Autocomplete Suggestions
  Future<List<dynamic>> fetchAutocompleteSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'] ?? [];
    } else {
      throw Exception('Failed to fetch autocomplete suggestions');
    }
  }

  // 9. Favorites (Storing locally)
  List<int> favorites = [];

  void addToFavorites(int recipeId) {
    if (!favorites.contains(recipeId)) {
      favorites.add(recipeId);
    }
  }

  void removeFromFavorites(int recipeId) {
    favorites.remove(recipeId);
  }

  bool isFavorite(int recipeId) {
    return favorites.contains(recipeId);
  }
}
