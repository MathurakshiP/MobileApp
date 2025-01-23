import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/category_screen.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';
import 'package:mobile_app/Screens/search_results_screen.dart';
import 'package:mobile_app/Services/api_services.dart';

class AddFoodScreen extends StatefulWidget {
  final String userId;
  
  const AddFoodScreen({super.key, required this.userId});
  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool isMealPlan=true;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _navigateToSearchScreen() async {
    final selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );

    if (selectedFood != null) {
      Navigator.pop(context, selectedFood); // Pass the selected food back to MealPlannerScreen
    }
  }

  void _navigateToCategoryScreen(String category) async {
    final selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          category: category,
          userId: widget.userId,
          isMealPlan: isMealPlan,
        ),
      ),
    );

    if (selectedFood != null) {
      Navigator.pop(context, selectedFood); // Pass the selected food back to MealPlannerScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Food',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section Title
            Text(
              'Search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Search Bar
            GestureDetector(
              onTap: _navigateToSearchScreen,
              child: TextField(
                controller: _searchController,
                enabled: false, // Disable direct input
                decoration: InputDecoration(
                  labelText: 'Search Food...',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search by Meal Section
            Text(
              'Search by Meal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildMealCard('Breakfast', 'images/breakfast.jpg'),
                  _buildMealCard('Lunch', 'images/lunch.jpg'),
                  _buildMealCard('Dinner', 'images/dinner.jpg'),
                  _buildMealCard('Salad', 'images/salad.jpg'),
                  _buildMealCard('Soup', 'images/soup.jpg'),
                  _buildMealCard('Dessert', 'images/dessert.jpg'),
                ],
              ),
            ),
          ],
        ), 
      ),
    );
  }

  // Helper Method to Build Meal Cards
  Widget _buildMealCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        _navigateToCategoryScreen( title);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService(); // Replace with your actual API service
  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _recentlyViewed = [];
  bool isMealPlan=true;
  @override
  void dispose() {
    _searchController.dispose();
    _suggestions.clear();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
        });
        return;
      }

      try {
        final results = await _apiService.fetchAutocompleteSuggestions(query);
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(results);
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching autocomplete suggestions: $e");
        }
      }
    });
  }

  void _onSuggestionTap(Map<String, dynamic> suggestion) {
    _recentlyViewed.insert(0, suggestion);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RecipeDetailScreen(recipeId: suggestion['id']), // Replace with your detail screen
      ),
    );
    _searchController.clear();
    setState(() {
      _suggestions = [];
    });
  }

  void _searchFood() async {
    final query = _searchController.text;

    if (query.isNotEmpty) {
      try {
        final results = await _apiService.fetchRecipes(query); // Replace with your actual API call
        setState(() {
          _suggestions = [];
        });
        final selectedFood = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              searchQuery: query,
              recipes: results, // Pass the list of foods
              isMealPlan: isMealPlan,
            ),
          ),
        );

        if (selectedFood != null) {
          Navigator.pop(context, selectedFood); // Pass the selected food back to MealPlannerScreen
        }
       
      } catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load foods. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Food',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (query) => _onSearchChanged(query),
              decoration: InputDecoration(
                labelText: 'Search Food...',
                labelStyle: TextStyle(color: Colors.purple),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.purple,
                  ),
                  onPressed: _searchFood,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Suggestions List
            if (_suggestions.isNotEmpty)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      var suggestion = _suggestions[index];
                      return ListTile(
                        title: Text(suggestion['title'] ?? 'No Title'),
                        onTap: () => _onSuggestionTap(suggestion),
                      );
                    },
                  ),
                ),
              ),
            if (_suggestions.isEmpty && _searchController.text.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}







