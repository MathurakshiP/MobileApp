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

  List<Widget> buildIngredientWidgets(List<String> ingredients) {
  return ingredients.map((ingredient) {
    return GestureDetector(
      onTap: () => _addIngredient(ingredient),
      child: Chip(
        label: Text(ingredient),
        backgroundColor: Colors.grey[200],
        side: const BorderSide(color: Colors.black12),
      ),
    );
  }).toList();
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
              // Chips for ingredients in a scrollable view
              Expanded(  // Ensures the child scrolls if necessary
                child: SingleChildScrollView(  // Makes the ingredients list scrollable
                  child: Wrap(
                    spacing: 4.0, // Horizontal space between chips
                    runSpacing: -4.0, // Vertical space between chips
                    children: buildIngredientWidgets(ingredients),
                  ),
                ),
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
    body: ListView(  // Using ListView for the entire screen
      padding: const EdgeInsets.all(16.0),
      children: [
        // Search bar
        Container(
  padding: const EdgeInsets.all(16.0), // Padding for the entire container
  child: Column(  // Use Column to arrange all child widgets vertically
    children: [
      // Search bar (TextField for entering ingredients)
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

      // Additional ingredients containers
      buildIngredientContainer('Vegetables & Greens', Vegetables),
      buildIngredientContainer('Fruits', Fruits),
    ],
  ),
),

        

        // Recipe results
        if (_recipes.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('No recipes found.'),
            ),
          )
        else
          // Use ListView to display recipe results without a fixed height
          Container(
            height: 400.0, // Define a fixed height for the recipe list
            child: ListView.builder(
              shrinkWrap: true,  // Ensures ListView doesn't take unnecessary space
              physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return ListTile(
                  leading: recipe['image'] != null
                      ? Image.network(
                          recipe['image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
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
          ),
      ],
    ),
  );
}

}
