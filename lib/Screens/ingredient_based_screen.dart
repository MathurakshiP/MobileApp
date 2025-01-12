import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Services/api_services.dart';

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  _IngredientSearchScreenState createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final Set<String> _selectedIngredients = {};
  List<dynamic> _recipes = [];
  bool _isLoading = false;

  // Custom colors
  final Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);

  // Ingredient sets
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
    'Vinegar',
    'Salt',
    'Honey',
    'Cinnamon',
    'Nutmeg',
  ];
  final List<String> vegetables = [
    'Tomato',
    'Cheese',
    'Chicken',
    'Lemon',
    'Pepper',
    'Spinach',
    'Carrot',
    'Broccoli',
    'Cabbage',
    'Zucchini',
    'Cauliflower',
    'Potato',
    'Cucumber',
    'Radish',
    'Peas',
  ];
  final List<String> fruits = [
    'Apple',
    'Banana',
    'Orange',
    'Strawberry',
    'Blueberry',
    'Pineapple',
    'Grapes',
    'Watermelon',
    'Mango',
    'Peach',
    'Cherry',
    'Pear',
    'Kiwi',
    'Lime',
    'Plum',
  ];
  final List<String> dairyProducts = [
    'Milk',
    'Cheese',
    'Yogurt',
    'Butter',
    'Cream',
    'Paneer',
    'Ghee',
    'Curd',
    'Whipped Cream',
    'Buttermilk',
    'Kefir',
    'Sour Cream',
    'Condensed Milk',
    'Goat Cheese',
    'Mozzarella',
  ];

  final List<String> grains = [
    'Rice',
    'Wheat',
    'Oats',
    'Barley',
    'Corn',
    'Quinoa',
    'Buckwheat',
    'Millet',
    'Rye',
    'Sorghum',
    'Bulgur',
    'Couscous',
    'Wild Rice',
    'Teff',
    'Amaranth',
  ];

  final List<String> spicesHerbs = [
    'Basil',
    'Coriander',
    'Cumin',
    'Turmeric',
    'Black Pepper',
    'Paprika',
    'Parsley',
    'Thyme',
    'Rosemary',
    'Oregano',
    'Saffron',
    'Ginger',
    'Nutmeg',
    'Cloves',
    'Dill',
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

      // Update the search bar content
      _ingredientController.text = _selectedIngredients.join(', ');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      labelText: 'Enter ingredients (comma-separated)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
                buildCollapsibleContainer(
                    'Pantry Ingredients', pantryIngredients),
                buildCollapsibleContainer('Vegetables & Greens', vegetables),
                buildCollapsibleContainer('Fruits', fruits),
                buildCollapsibleContainer('Fruits', fruits),
                buildCollapsibleContainer('Dairy Products', dairyProducts),
                buildCollapsibleContainer('Grains', grains),
                buildCollapsibleContainer('Spices & Herbs', spicesHerbs),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: Container(
                color: Colors.black54,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return ListView(
                        children: _selectedIngredients.map((ingredient) {
                          return ListTile(
                            title: Text(ingredient),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _selectedIngredients.remove(ingredient);
                                  _ingredientController.text =
                                      _selectedIngredients.join(', ');
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
                child: Text('My Pantry (${_selectedIngredients.length})'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('See Recipes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
