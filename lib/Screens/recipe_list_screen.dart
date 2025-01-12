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
                    child: ListTile(
                      title: Text(recipe['title'] ?? 'Recipe'),
                      leading: recipe['image'] != null
                          ? Image.network(recipe['image'])
                          : const Icon(Icons.image),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
