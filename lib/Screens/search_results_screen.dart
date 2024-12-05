import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';
// ignore: must_be_immutable
class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;
  final List<dynamic> recipes;

  SearchResultsScreen({super.key, required this.searchQuery, required this.recipes});
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$searchQuery"'),
        backgroundColor: customPurple,
      ),
      body: recipes.isEmpty
          ? Center(child: Text('No results found for "$searchQuery"'))
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: recipe['image'] != null
                      ? Image.network(recipe['image'], width: 50, height: 50)
                      : null,
                  title: Text(recipe['title']),
                  subtitle: Text(recipe['readyInMinutes'] != null
                      ? 'Ready in ${recipe['readyInMinutes']} minutes'
                      : 'No time info'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipeId: recipe['id']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
