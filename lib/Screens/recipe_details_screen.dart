// lib/screens/recipe_detail_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:mobile_app/Services/api_services.dart';
import 'package:mobile_app/providers/saved_food_provider.dart';
import 'package:mobile_app/providers/shopping_list_provider.dart';

// ignore: must_be_immutable
class RecipeDetailScreen extends StatelessWidget {
  final int recipeId;

  RecipeDetailScreen({super.key, required this.recipeId});
  Color customGreen = const Color.fromRGBO(20, 118, 21, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().fetchRecipeDetails(recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final recipe = snapshot.data!;
            final savedFoodProvider = Provider.of<SavedFoodProvider>(context);
            final shoppingListProvider = Provider.of<ShoppingListProvider>(context);

            // Check if the recipe is already saved
            bool isSaved = savedFoodProvider.savedRecipes
                .any((savedRecipe) => savedRecipe['id'] == recipeId);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (recipe['image'] != null)
                  Image.network(recipe['image'], height: 200, fit: BoxFit.cover),
                const SizedBox(height: 16),
                Text(recipe['title'], style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text('Cooking Time: ${recipe['readyInMinutes']} minutes'),
                const SizedBox(height: 16),
                // Buttons for saving the recipe and adding ingredients to the shopping list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        // Toggle saved state
                        if (isSaved) {
                          savedFoodProvider.removeRecipe(recipe);
                        } else {
                          savedFoodProvider.addRecipe(recipe);
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Extract the ingredients from the recipe and convert them to a List<String>
                        final ingredients = recipe['extendedIngredients']?.map<String>((i) => i['original'].toString()).toList() ?? [];

                        if (ingredients.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No ingredients found to add to the shopping list.')),
                          );
                          return;
                        }

                        if (kDebugMode) {
                          print('Adding ingredients to shopping list: $ingredients');
                        }

                        shoppingListProvider.addItems(ingredients);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ingredients added to shopping list!')),
                        );
                      },
                      child: const Text('Add to Shopping List'),
                    ),


                  ],
                ),
                const SizedBox(height: 16),
                const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...List.generate(recipe['extendedIngredients']?.length ?? 0, (index) {
                  return Text('- ${recipe['extendedIngredients'][index]['original']}');
                }),
                const SizedBox(height: 16),
                const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(recipe['instructions'] ?? 'No instructions available.'),
              ],
            );
          }
        },
      ),
    );
  }
}
