import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/screens/recipe_list_screen.dart'; // Import RecipeListScreen

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  _IngredientSearchScreenState createState() =>
      _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final Set<String> _selectedIngredients = {}; // For selected ingredients
  List<dynamic> _recipes = [];
  bool _isLoading = false;

  // Custom colors
  final Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);

  // Ingredient sets
  final List<String> pantryIngredients = [
    'Butter', 'Egg', 'Garlic', 'Milk', 'Onion',
    'Sugar', 'Flour', 'Olive Oil', 'Garlic Powder', 'White Rice',
    'Vinegar', 'Salt', 'Honey', 'Cinnamon', 'Nutmeg'
  ];
  final List<String> vegetables = [
    'Tomato', 'Cheese', 'Chicken', 'Lemon', 'Pepper',
    'Spinach', 'Carrot', 'Broccoli', 'Cabbage', 'Zucchini',
    'Cauliflower', 'Potato', 'Cucumber', 'Radish', 'Peas'
  ];
  final List<String> fruits = [
    'Apple', 'Banana', 'Orange', 'Strawberry', 'Blueberry',
    'Pineapple', 'Grapes', 'Watermelon', 'Mango', 'Peach',
    'Cherry', 'Pear', 'Kiwi', 'Lime', 'Plum'
  ];
  final List<String> dairyProducts = [
    'Milk', 'Cheese', 'Yogurt', 'Butter', 'Cream',
    'Paneer', 'Ghee', 'Curd', 'Whipped Cream', 'Buttermilk',
    'Kefir', 'Sour Cream', 'Condensed Milk', 'Goat Cheese', 'Mozzarella'
  ];
  final List<String> grains = [
    'Rice', 'Wheat', 'Oats', 'Barley', 'Corn', 'Quinoa',
    'Buckwheat', 'Millet', 'Rye', 'Sorghum', 'Bulgur',
    'Couscous', 'Wild Rice', 'Teff', 'Amaranth'
  ];
  final List<String> spicesHerbs = [
    'Basil', 'Coriander', 'Cumin', 'Turmeric', 'Black Pepper',
    'Paprika', 'Parsley', 'Thyme', 'Rosemary', 'Oregano',
    'Saffron', 'Ginger', 'Nutmeg', 'Cloves', 'Dill'
  ];

  final Map<String, bool> isExpanded = {
    'Pantry Ingredients': false,
    'Vegetables & Greens': false,
    'Fruits': false,
    'Dairy Products': false,
    'Grains': false,
    'Spices & Herbs': false,
  };

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  List<Widget> buildIngredientWidgets(List<String> ingredients) {
    return ingredients.map((ingredient) {
      final isSelected = _selectedIngredients.contains(ingredient);
      return GestureDetector(
        onTap: () => _toggleIngredient(ingredient),
        child: Chip(
          label: Text(
            ingredient,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
          backgroundColor: isSelected ? selectedPurple : customPurple,
          side: const BorderSide(color: Colors.white),
        ),
      );
    }).toList();
  }

  Widget buildCollapsibleContainer(String title, List<String> ingredients) {
    final bool expanded = isExpanded[title] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded[title] = !expanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Icon(expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                  ],
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Wrap(
                  spacing: 4.0,
                  children: buildIngredientWidgets(
                      ingredients.take(4).toList()), // Show only 4 chips
                ),
                secondChild: Wrap(
                  spacing: 4.0,
                  children:
                      buildIngredientWidgets(ingredients), // Show all chips
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to fetch recipes from the API
  Future<void> fetchRecipes() async {
    // Get typed ingredients from the text field
    List<String> typedIngredients = _ingredientController.text.isNotEmpty
        ? _ingredientController.text.split(',').map((e) => e.trim()).toList()
        : [];

    // Merge typed ingredients with selected ingredients
    List<String> allIngredients = [...typedIngredients, ..._selectedIngredients];

    if (allIngredients.isEmpty) {
      print("No ingredients selected or typed");
      return;
    }

    setState(() {
      _isLoading = true;
      _recipes = [];
    });

    final String apiUrl =
        'https://api.spoonacular.com/recipes/findByIngredients?ingredients=${allIngredients.join(',')}&apiKey=a2e8aeca685d4b33975aa0fec27c5fb3';
    print("Fetching recipes with URL: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          print("No recipes found");
        } else {
          print("Recipes fetched successfully");
        }
        setState(() {
          _recipes = data;
          _isLoading = false;
        });

        // Navigate to the new RecipeListScreen with the fetched recipes
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeListScreen(recipes: _recipes),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Failed to load recipes. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching recipes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combine the selected ingredients and typed ingredients to show in the text field
    String allIngredientsText = [
      ..._selectedIngredients,
      ..._ingredientController.text.split(',').map((e) => e.trim())
    ].join(', ');

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _ingredientController,
                      decoration: InputDecoration(
                        labelText: 'Enter ingredients (comma-separated)',
                        labelStyle: TextStyle(color: customPurple), // Placeholder text color
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: customPurple), // Search icon color
                          onPressed: fetchRecipes, // Directly fetch recipes on search icon click
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          // Update the ingredients text dynamically
                        });
                      },
                    ),
                  ),
                  // Display the selected ingredients at the top of the screen
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Wrap(
                      spacing: 4.0,
                      children: buildIngredientWidgets([..._selectedIngredients]),
                    ),
                  ),
                  buildCollapsibleContainer('Pantry Ingredients', pantryIngredients),
                  buildCollapsibleContainer('Vegetables & Greens', vegetables),
                  buildCollapsibleContainer('Fruits', fruits),
                  buildCollapsibleContainer('Dairy Products', dairyProducts),
                  buildCollapsibleContainer('Grains', grains),
                  buildCollapsibleContainer('Spices & Herbs', spicesHerbs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
