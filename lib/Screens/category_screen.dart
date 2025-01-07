import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<dynamic> _categoryRecipes = [];
  bool _isLoading = false;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  // Filter variables
  String? _selectedCuisine;
  String? _selectedTime;
  List<String> cuisines = [
    'African', 'Asian', 'American', 'British', 'Cajun', 'Caribbean', 'Chinese', 
    'Eastern European', 'European', 'French', 'German', 'Greek', 'Indian', 'Irish', 
    'Italian', 'Japanese', 'Jewish', 'Korean', 'Latin American', 'Mediterranean', 
    'Mexican', 'Middle Eastern', 'Nordic', 'Southern', 'Spanish', 'Thai', 'Vietnamese'
  ];

  List<String> times = ['Any', 'Less than 15 minutes', '15 - 30 minutes', '30 - 60 minutes', 'More than 60 minutes'];

  @override
  void initState() {
    super.initState();
    fetchRelatedRecipes();
  }

  // Fetch related recipes for the category
  void fetchRelatedRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await ApiService().fetchRandomRecipes(); // Update this ID if needed
      List<dynamic> filteredRecipes = [];
      for (var recipe in recipes) {
        final String lunch = "lunch";
        final String breakfast = "breakfast";
        final String dinner = "dinner";
        final String dessert = "dessert";
        
        // Apply category-based filtering
        if (recipe['dishTypes'] != null) {
          if (widget.category == "Breakfast" && recipe['dishTypes'].contains(breakfast)) {
            filteredRecipes.add(recipe);
          } else if (widget.category == "Lunch" && recipe['dishTypes'].contains(lunch)) {
            filteredRecipes.add(recipe);
          } else if (widget.category == "Dinner" && recipe['dishTypes'].contains(dinner)) {
            filteredRecipes.add(recipe);
          } else if (widget.category == "Dessert" && recipe['dishTypes'].contains(dessert)) {
            filteredRecipes.add(recipe);
          }
        }

        // Apply cuisine filter
        if (_selectedCuisine != null && _selectedCuisine != 'Any') {
          if (!recipe['cuisine'].contains(_selectedCuisine)) {
            continue;  // Skip recipes that don't match the selected cuisine
          }
        }

        // Apply time filter (assuming each recipe has a 'time' field in minutes)
        if (_selectedTime != null && _selectedTime != 'Any') {
          int recipeTime = recipe['readyInMinutes'] ?? 0;
          if (_selectedTime == 'Less than 15 minutes' && recipeTime <= 15) {
            continue;
          } else if (_selectedTime == '15 - 30 minutes' && (recipeTime > 15 && recipeTime < 30)) {
            continue;
          } else if (_selectedTime == '30 - 60 minutes' && (recipeTime > 30 && recipeTime > 60)) {
            continue;
          } else if (_selectedTime == 'More than 60 minutes' && recipeTime >= 60) {
            continue;
          }
        }
      }

      setState(() {
        _categoryRecipes = filteredRecipes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching recipes for category ${widget.category}: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load recipes. Please try again later.')),
      );
    }
  }

  // Handle filter apply button press
  void _applyFilters() {
    fetchRelatedRecipes();  // Re-fetch recipes with the new filters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category, style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white, 
          fontSize: 20,
        )),
        backgroundColor: customPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Dropdowns
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          hint: Text('Select Cuisine'),
                          value: _selectedCuisine,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCuisine = newValue;
                            });
                          },
                          items: ['Any', ...cuisines].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          hint: Text('Select Time'),
                          value: _selectedTime,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedTime = newValue;
                            });
                          },
                          items: times.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply Filters'),
                ),
                // Recipe List
                Expanded(
                  child: _categoryRecipes.isEmpty
                      ? Center(child: Text('No recipes available for ${widget.category}.'))
                      : ListView.builder(
                          itemCount: _categoryRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _categoryRecipes[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              leading: recipe['image'] != null
                                  ? Image.network(
                                      recipe['image'],
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 50,
                                          width: 50,
                                          color: Colors.grey,
                                          child: const Icon(Icons.broken_image, size: 30, color: Colors.white),
                                        );
                                      },
                                    )
                                  : Container(
                                      height: 50,
                                      width: 50,
                                      color: Colors.grey,
                                      child: const Icon(Icons.fastfood, size: 30, color: Colors.white),
                                    ),
                              title: Text(
                                recipe['title'] ?? 'No Title',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
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
                ),
              ],
            ),
    );
  }
}
