// lib/screens/recipe_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/auth.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:mobile_app/Services/api_services.dart';
import 'package:mobile_app/providers/saved_food_provider.dart';
import 'package:mobile_app/providers/shopping_list_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final int recipeId;

  RecipeDetailScreen({super.key, required this.recipeId});
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Details',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the text bold
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
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

            // Save the recently viewed recipe
            Auth().saveRecentlyViewedRecipe(
              recipe['id'].toString(),
              recipe['title'],
              recipe['image']
            );

            // Check if the recipe is already saved
            bool isSaved = savedFoodProvider.savedRecipes
                .any((savedRecipe) => savedRecipe['id'] == recipeId);

            // Extract instructions from the recipe data
            final instructions = recipe['analyzedInstructions'] ?? [];

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
                      onPressed: () async {
                        final recipeTitle = recipe['title'] ?? 'Unnamed Recipe'; // Use the recipe title or a fallback
                        final ingredients = recipe['extendedIngredients']
                                ?.map<String>((i) => i['original'].toString())
                                .toList() ??
                            [];

                        if (ingredients.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No ingredients found to add to the shopping list.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        try {
                          // Add ingredients to the shoppingListProvider (local state management and Firestore)
                          await shoppingListProvider.addRecipeIngredients(recipeTitle, ingredients);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$recipeTitle ingredients added to the shopping list.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          // Handle errors
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add $recipeTitle ingredients: $e'),
                              duration: const Duration(seconds: 3),
                            ),
                          );

                          if (kDebugMode) {
                            print('Error adding ingredients: $e');
                          }
                        }
                      },
                      child: const Text('Add to Shopping List'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Ingredient', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Measurement', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List.generate(recipe['extendedIngredients']?.length ?? 0, (index) {
                      final ingredient = recipe['extendedIngredients'][index];
                      final nameWithMeasurement = ingredient['original'] ?? '';
                      final name = _extractIngredientName(nameWithMeasurement);
                      final measurement = _extractMeasurement(ingredient);
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(name)),
                          DataCell(Text(measurement)),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Directly use _buildInstructionSections with the fetched instructions data
                ..._buildInstructionSections(instructions),
              ],
            );
          }
        },
      ),
    );
  }

  // Function to extract only the ingredient name (without the measurement)
  String _extractIngredientName(String ingredient) {
    // Regular expression to match and remove measurement part (like "1/2 cup", "1 cup", etc.)
    final regExp = RegExp(r'^[0-9\/\.\-\+\*\s]*');
    return ingredient.replaceFirst(regExp, '').trim();
  }

  // Function to extract the full measurement as a string (preserving the fraction, like "1/2 cup")
  String _extractMeasurement(Map<String, dynamic> ingredient) {
    final amount = ingredient['amount']?.toString() ?? '';
    final unit = ingredient['unit'] ?? '';

    // Handle fractions as strings (e.g., "1/2 cup" instead of "0.5 cup")
    final originalMeasurement = ingredient['originalString'] ?? '';
    if (originalMeasurement.isNotEmpty) {
      return originalMeasurement; // Use the original string directly
    }

    // If originalString is not available, use the amount and unit
    return '$amount $unit';
  }
  
  // Function to handle displaying instructions
  List<Widget> _buildInstructionSections(List<dynamic> instructionData) {
    if (instructionData == null || instructionData.isEmpty) {
      return [const Text('No instructions available.', style: TextStyle(fontStyle: FontStyle.italic))];
    }

    return instructionData.map<Widget>((instruction) {
      final steps = (instruction['steps'] as List<dynamic>?) ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (instruction['name'] != null && instruction['name'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                instruction['name'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (steps.isEmpty)
            const Text('No steps available.', style: TextStyle(fontStyle: FontStyle.italic)),
          // The entire instruction section in a rounded black container with white text
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: customPurple,
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...steps.map<Widget>((step) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display step number and step description in white text
                        Text(
                          '${step['number']}. ${step['step']}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        // White divider line after each step
                        const Divider(
                          color: Colors.white, // White divider
                          thickness: 1,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
