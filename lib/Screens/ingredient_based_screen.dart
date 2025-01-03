import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Services/api_services.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  _IngredientSearchScreenState createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  List<dynamic> _recipes = [];
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  final List<String> pantryIngredients = [
    'Butter',
    'Egg',
    'Garlic',
    'Milk',
    'Onion',
    'Sugar',
    'Flour',
    'Olive Oil',
    'Garlic Powder',
    'White Rice',
    'Sugar',
    'Flour',
    'Olive Oil',
    'Garlic Powder',
    'White Rice',
  ];

  final List<String> Vegetables = [
    'Tomato',
    'Cheese',
    'Chicken',
    'Lemon',
    'Pepper',
    'Salt',
    'Tomato',
    'Cheese',
    'Chicken',
    'Lemon',
    'Pepper',
    'Salt',
    'Tomato',
    'Cheese',
    'Chicken',
    'Lemon',
    'Pepper',
    'Salt',
  ];

  final List<String> Fruits = [
    'Tomato',
    'Cheese',
    'Chicken',
    'Lemon',
    'Pepper',
    'Salt',
    'Tomato',
    'Cheese',
    'Chicken',
    'Lemon',
    'Pepper',
    'Salt',
    'Tomato',
    'Cheese',
    'Chicken',
    'Lemon',
    'Pepper',
    'Salt',
  ];

  void _searchByIngredients() async {
    final ingredients = _ingredientController.text
        .split(',')
        .map((ingredient) => ingredient.trim())
        .toList();

    if (ingredients.isNotEmpty) {
      try {
        final apiService = ApiService();
        final recipes = await apiService.fetchRecipesByIngredients(ingredients);
        setState(() {
          _recipes = recipes;
        });
      } catch (error) {
        if (kDebugMode) {
          print('Error: $error');
        }
      }
    }
  }

  void _addIngredient(String ingredient) {
    _ingredientController.text +=
        _ingredientController.text.isEmpty ? ingredient : ', $ingredient';
    setState(() {}); // Refresh the UI if necessary
  }

  Widget buildIngredientContainer(String title, List<String> ingredients) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        width: 400.0, // Fixed width for all containers
        height: 330.0, // Fixed height for all containers
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container title
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                // Chips for ingredients
                Wrap(
                  spacing: 4.0, // Horizontal space between chips
                  runSpacing: -4.0, // Vertical space between chips
                  children: ingredients.map((ingredient) {
                    return GestureDetector(
                      onTap: () => _addIngredient(ingredient),
                      child: Chip(
                        label: Text(ingredient),
                        backgroundColor: Colors.grey[200],
                        side: const BorderSide(color: Colors.black12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Search'),
        backgroundColor: customPurple,
      ),
      body: SingleChildScrollView(  // Wrap the body in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    labelText: 'Enter ingredients (comma-separated)',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchByIngredients,
                    ),
                  ),
                ),
              ),
              
              // Pantry ingredients container
              buildIngredientContainer('Pantry Ingredients', pantryIngredients),
              
              // Additional ingredients container
              buildIngredientContainer('Vegetables & Greens', Vegetables),
              buildIngredientContainer('Fruits', Fruits),

              // Recipe results
              _recipes.isEmpty
                  ? const Center(child: Text('No recipes found.'))
                  : ListView.builder(
                      shrinkWrap: true,  // Ensures ListView doesn't take unnecessary space
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return ListTile(
                          leading: recipe['image'] != null
                              ? Image.network(recipe['image'], width: 100, height: 100)
                              : null,
                          title: Text(recipe['title']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(recipeId: recipe['id']),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
