import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/Screens/recipe_details_screen.dart';

class RecipeListScreen extends StatefulWidget {
  final List<dynamic> recipes;
  const RecipeListScreen({super.key, required this.recipes});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<dynamic> recipes = [];
  final String _baseUrl = 'https://api.spoonacular.com';
  final String _apiKey = 'd4c56c9b18204389b1cb841224e22618';

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recipes/complexSearch?apiKey=$_apiKey&addRecipeInformation=true'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Full API Response: $data');

        if (data.containsKey('results') && data['results'].isNotEmpty) {
          setState(() {
            recipes = data['results'];
          });
          print('Fetched ${recipes.length} recipes.');
        } else {
          print('No recipes found in response.');
        }
      } else {
        print('Failed to fetch recipes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: recipes.isEmpty
          ? const Center(
              child: Text(
                "No recipes found. Please try again later.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final randomLikes = (100 + index * 10).toString();

                return GestureDetector(
                  onTap: () {
                    final recipeId = recipe['id'];
                    if (recipeId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(recipeId: recipeId),
                        ),
                      );
                    } else {
                      print('Recipe ID is null. Cannot navigate.');
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16.0),
                                bottom: Radius.circular(16.0)
                              ),
                              child: SizedBox(
                                width: 200,
                                height:150,
                                child: Image.network(
                                  recipe['image'] ?? '',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe['preparationMinutes'] != null &&
                                              recipe['preparationMinutes'] > 0
                                          ? '${recipe['preparationMinutes']} mins'
                                          : recipe['readyInMinutes'] != null
                                              ? '${recipe['readyInMinutes']} mins'
                                              : 'N/A',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.thumb_up,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      randomLikes,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            recipe['title'] ?? 'Recipe',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}