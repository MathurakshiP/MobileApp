import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/category_screen.dart';
import 'package:mobile_app/Screens/ingredient_based_screen.dart';
import 'package:mobile_app/Screens/meal_planner_screen.dart';
// import 'package:team_project/screens/category_screen.dart';
import 'package:mobile_app/screens/saved_food_screen.dart';
import 'package:mobile_app/screens/shopping_list_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart';  // Placeholder for Profile screen
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';
import 'package:mobile_app/screens/search_results_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  Timer? _debounce;
  List<dynamic> _recipes = [];
  List<dynamic> _randomRecipes = [];
  List<dynamic> _recentlyViewed = [];

  bool _isLoading = false;
  int _selectedIndex = 0;
  String? _selectedCategory;
  Color customGreen = const Color.fromRGBO(20, 118, 21, 1.0);

 
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRandomRecipes(); // Load random recipes on init
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  // Fetch random recipes for "Latest Recipes" section
  void _loadRandomRecipes() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final randomRecipes = await ApiService().fetchRandomRecipes(number: 3);
      setState(() {
        _randomRecipes = randomRecipes;
        _isLoading = false; // Stop loading once data is fetched
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop loading in case of error
      });
      if (kDebugMode) {
        print('Error fetching random recipes: $error');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load random recipes. Please try again later.')),
      );
    }
  }


  // Search function that fetches recipes based on user input
  void _searchRecipe() async {
    final query = _searchController.text;

    if (query.isNotEmpty) {
      try {
        final apiService = ApiService();
        final recipes = await apiService.fetchRecipes(query);

        setState(() {
          _recipes = recipes;
          _recentlyViewed= recipes;
        });

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(searchQuery: query, recipes: _recipes),
          ),
        );
      } catch (error) {
        if (kDebugMode) {
          print('Error: $error');
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load recipes. Please try again.')),
        );
      }
    }
  }

// Update this method to call the API
  // Update this method to call the API
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // Fetch suggestions from the API, matching the start of the query
      ApiService apiService = ApiService();
      try {
        var results = await apiService.fetchAutocompleteSuggestions(query);
        setState(() {
          _suggestions = results;
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching autocomplete suggestions: $e");
        }
      }
    });
  }

  void _onSuggestionTap(Map<String, dynamic> suggestion) {
  // Navigate to recipe details based on the selected suggestion

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipeId: suggestion['id'])),
  );
  _searchController.clear();
  setState(() {
    _suggestions = [];
  });
}



  // Bottom navigation bar action
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  // To show different app bar based on the current screen
  bool _isIconPressed = false; // Track the icon press state

  PreferredSizeWidget _buildAppBar() {
    if (_selectedIndex == 0) {
      // Home Screen AppBar
      return AppBar(
        title: const Row(
          children: [
            Text(
              'Cookify', // Top left title
              style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white,
                
              ),
            ),
          ],

        ),
        backgroundColor: customGreen,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today,
                color: _isIconPressed ? customGreen : Colors.white), // Change color based on state
            onPressed: () {
              // Toggle the icon color
              setState(() {
                _isIconPressed = !_isIconPressed;
              });
              
              // Navigate to meal plan screen or action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MealPlanScreen()),
              ).then((_) {
                // Reset icon color after returning from MealPlannerScreen
                setState(() {
                  _isIconPressed = false;
                });
              });
            },
          ),
        ],
      );
    } else {
      // Other Screens (do not show app bar)
      return PreferredSize(preferredSize: const Size(0, 0), child: Container());
    }
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),  // Use custom app bar method
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Screen Content
          SingleChildScrollView(  // Added scrollable functionality
            child: Column(
              children: [

                // Tab Navigation for Explore Recipe and What's in Your Kitchen
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Explore Recipe'),
                    Tab(text: "What's in Your Kitchen"),
                  ],
                  labelColor: Colors.black, // Selected tab color
                  unselectedLabelColor: Colors.black, // Unselected tab color
                  indicatorColor: Colors.black,
                ),
                

                SizedBox(
                    height: 1000,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Content for "Explore Recipe" tab
                        Column(
                          children: [
                                    // Search Bar
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (query) {
                                          // Call the function to handle search
                                          _onSearchChanged(query);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Search Recipe...',
                                          labelStyle: const TextStyle(color: Colors.black),
                                          border: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black),
                                        ),
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.search),
                                            onPressed: _searchRecipe,
                                          ),
                                        ),
                                      ),
                                    ),

                                 if (_suggestions.isNotEmpty)
                                  Positioned(
                                    top: 72,  // Adjust this to position the dropdown above the TextField
                                    left: 16,
                                    right: 16,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        // color: Colors.white,
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: _suggestions.length,
                                          itemBuilder: (context, index) {
                                            var suggestion = _suggestions[index]['title'] ?? '';
                                            return ListTile(
                                              title: Text(suggestion),
                                              onTap: () => _onSuggestionTap(_suggestions[index]),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                    
                                    // Horizontal tabs for meal categories
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildMealCategoryTab('Breakfast'),
                                            _buildMealCategoryTab('Lunch'),
                                            _buildMealCategoryTab('Dinner'),
                                            _buildMealCategoryTab('Dessert'),
                                          ],
                                        ),
                                      ),
                                    ),


                                    // Latest Recipes Section (Horizontally Scrollable)
                                    const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start, // Align text to the left
                                        children: [
                                          Text(
                                            'Latest Recipes',
                                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),

                                    _isLoading
                                        ? const CircularProgressIndicator() // Show loading indicator while fetching data
                                        : Padding(
                                            padding: const EdgeInsets.only(left: 16.0), // Add left padding here
                                            child: SizedBox(
                                              height: 250, // Adjust height as needed
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: _randomRecipes.length,
                                                itemBuilder: (context, index) {
                                                  final recipe = _randomRecipes[index];
                                                  return GestureDetector(
                                                    onTap: () {
                                                      // Navigate to the recipe details screen
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => RecipeDetailScreen(recipeId: recipe['id']),
                                                        ),
                                                      );
                                                    },
                                                    child: SizedBox(
                                                      width: 250, // Fixed width for the card
                                                      child: Card(
                                                        margin: const EdgeInsets.only(right: 16),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            // Image handling
                                                            recipe['image'] != null
                                                                ? Image.network(
                                                                    recipe['image'],
                                                                    height: 120,
                                                                    width: 250,
                                                                    fit: BoxFit.cover,
                                                                    errorBuilder: (context, error, stackTrace) {
                                                                      return const Icon(Icons.broken_image, size: 120); // Show icon if image is broken
                                                                    },
                                                                  )
                                                                : Container(
                                                                    height: 120,
                                                                    width: 120,
                                                                    color: Colors.grey, // Default placeholder color if no image
                                                                  ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Text(
                                                                recipe['title'] ?? 'No Title', // Display title or fallback text
                                                                style: const TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                    // Recently Viewed Foods Section

                                    const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start, // Align text to the left
                                          children: [
                                            Text(
                                              'Recently Viewed Foods',
                                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),

                                    _recentlyViewed.isEmpty
                                        ? const Center(child: Text('No recently viewed foods'))
                                        : SizedBox(
                                            height: 250, // Adjust height as needed
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _recentlyViewed.length,
                                              itemBuilder: (context, index) {
                                                final recipe = _recentlyViewed[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    // Navigate to the recipe details screen
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => RecipeDetailScreen(recipeId: recipe['id']),
                                                      ),
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    width: 250, // Fixed width for the card
                                                    child: Card(
                                                      margin: const EdgeInsets.only(right: 16),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // Image handling
                                                          recipe['image'] != null
                                                              ? Image.network(
                                                                  recipe['image'],
                                                                  height: 120,
                                                                  width: 250,
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return const Icon(Icons.broken_image, size: 120); // Show icon if image is broken
                                                                  },
                                                                )
                                                              : Container(
                                                                  height: 120,
                                                                  width: 250, // Ensuring image container is fixed size
                                                                  color: Colors.grey, // Default placeholder color if no image
                                                                ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(
                                                              recipe['title'] ?? 'No Title', // Display title or fallback text
                                                              style: const TextStyle(fontSize: 16),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                          ],
                        ),

                        const IngredientSearchScreen(),
                      ],
                    ),
                ),

              ],
            ),
          ),

            const SavedFoodScreen(),
            // ShoppingListScreen with passed shoppingList
            const ShoppingListScreen(),
            // ProfileScreen
             ProfileScreen(),
        ],
      ),
      

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // Ensures fixed positions for icons
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home',),
          BottomNavigationBarItem(icon: Icon(Icons.favorite),label: 'Saved',),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart),label: 'Shopping List',),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile',),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: customGreen,  // Color for selected item
        unselectedItemColor: Colors.black, // Color for unselected items
        selectedFontSize: 14,  // Size of selected item's text
        unselectedFontSize: 12, // Size of unselected items' text
        iconSize: 28,           // Uniform icon size
        showUnselectedLabels: true,  // Keeps labels for unselected items
      ),



    );
  }

  
  Widget _buildMealCategoryTab(String category) {
    bool isSelected = _selectedCategory == category;  // Check if the category is selected
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;  // Update the selected category
        });
        // Navigate to the category screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(category: category),
          ),
        );
      },
      child: Container(
        width: 100,  // Fixed width for the tab
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isSelected ? customGreen : Colors.white,  // Selected tab in green, unselected in white
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : customGreen,  // White border for selected, green for unselected
            width: 2,
          ),
          // Shadow for selected tab
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : customGreen,  // White text for selected, green text for unselected
              fontWeight: FontWeight.bold,  // Bold text
            ),
          ),
        ),
      ),
    );
}

}
