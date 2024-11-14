import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';
import 'package:mobile_app/providers/saved_food_provider.dart';
import 'package:provider/provider.dart'; // Import Provider package
// import 'package:mobile_app/providers/saved_food_provider.dart';
// import 'package:mobile_app/screens/recipe_details_screen.dart'; // Import RecipeDetailScreen

class SavedFoodScreen extends StatelessWidget {
  const SavedFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedFoodProvider = Provider.of<SavedFoodProvider>(context);
    final savedRecipes = savedFoodProvider.savedRecipes;
    Color customGreen = const Color.fromRGBO(20, 118, 21, 1.0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        backgroundColor: customGreen,
        automaticallyImplyLeading: false,
      ),
      body: savedRecipes.isNotEmpty
          ? ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return ListTile(
                  leading: recipe['image'] != null
                      ? Image.network(recipe['image'], width: 50, height: 50)
                      : null,
                  title: Text(recipe['title']),
                  subtitle: Text(recipe['readyInMinutes'] != null
                      ? 'Ready in ${recipe['readyInMinutes']} minutes'
                      : 'No time info'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      // Remove the recipe from saved list
                      savedFoodProvider.removeRecipes(recipe);
                    },
                  ),
                  onTap: () {
                    // Navigate to RecipeDetailScreen when a recipe is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipeId: recipe['id']),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(
              child: Text('No saved recipes yet!'),
            ),
    );
  }
}
