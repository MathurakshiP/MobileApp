import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';

class RecipeListScreen extends StatelessWidget {
  final List<dynamic> recipes;

  const RecipeListScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
      ),
      body: recipes.isEmpty
          ? const Center(child: Text("No recipes found."))
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to RecipeDetailScreen when a recipe is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          recipeId: recipe['id'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0), // Gap between items
                    child: Column(
                      children: [
                        recipe['image'] != null
                            ? Image.network(
                                recipe['image'],
                                width: double.infinity, // Fill the width
                                height: 250, // Set a fixed height for the image
                                fit: BoxFit.cover, // Make sure the image covers the space
                              )
                            : const Icon(Icons.image, size: 80),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            recipe['title'] ?? 'Recipe',
                            style: TextStyle(
                              fontSize: 18, // Font size for the title
                              fontWeight: FontWeight.bold,
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
