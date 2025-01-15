import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/allrecipe_screen.dart';
import 'package:mobile_app/Screens/category_screen.dart';
import 'package:mobile_app/Screens/ingredient_based_screen.dart';
import 'package:mobile_app/Screens/meal_planner_screen.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:mobile_app/screens/saved_food_screen.dart';
import 'package:mobile_app/screens/shopping_list_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart'; 
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';
import 'package:mobile_app/screens/search_results_screen.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  Timer? _debounce;
  List<dynamic> _recipes = [];
  List<dynamic> _randomRecipes = [];
  List<dynamic> _recentlyViewed = [];
  late List<int> likeCounts;
  late List<bool> isLiked;
  bool _isIconPressed = false; 
  bool _isLoading = false;
  int _selectedIndex = 0;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRandomRecipes(); // Load random recipes on init
    final random = Random();
    likeCounts = List.generate(10,(_) => random.nextInt(20) + 1); // Random like count between 1 and 100
    isLiked = List.generate(10, (_) => false); // Initial liked state
  }

  @override
  void dispose() {
    _tabController.dispose();
     _searchController.dispose();
  _suggestions.clear();
    super.dispose();
  }

  void toggleLike(int index) {
    setState(() {
      isLiked[index] = !isLiked[index];
      likeCounts[index] += isLiked[index] ? 1 : -1;
    });
  }

  void _loadRandomRecipes() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final randomRecipes = await ApiService().fetchRandomRecipes(number: 10);
      final recipesWithImages = randomRecipes
          .where((recipe) => recipe['image'] != null && recipe['image'].isNotEmpty)
          .toList();

      setState(() {
        _randomRecipes = recipesWithImages;
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
        const SnackBar(
            content:
                Text('Failed to load random recipes. Please try again later.')),
      );
    }
  }

  void _searchRecipe() async {
    final query = _searchController.text;

    if (query.isNotEmpty) {
      try {
        final apiService = ApiService();
        final recipes = await apiService.fetchRecipes(query);

        setState(() {
          _recipes = recipes;
          _suggestions = [];
        });
 _searchController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
              searchQuery: query,
              recipes: _recipes,
            ),
          ),
        );
       
        
      } catch (error) {
        if (kDebugMode) {
          print('Error: $error');
        }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load recipes. Please try again.'),
        ),
      );
    }
  }
}

  void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () async {
    ApiService apiService = ApiService();
    
    try {
      final results = await apiService.fetchAutocompleteSuggestions(query);
      print('API Results: $results');  // Debug print
      setState(() {
        _suggestions = results;
      });
      print('Suggestions: $_suggestions');
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
          builder: (context) => RecipeDetailScreen(recipeId: suggestion['id'])),
    );
    _searchController.clear();
    setState(() {
      _suggestions = [];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  
  PreferredSizeWidget _buildAppBar() {
    if (_selectedIndex == 0) {
      return AppBar(
        title: const Row(
          children: [
            Text(
              'Cookify', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ],
        ),
        backgroundColor: customPurple,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today,
                color: _isIconPressed
                    ? customPurple: Colors.white), // Change color based on state
            onPressed: () {
              setState(() {
                  _isIconPressed = !_isIconPressed;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MealPlanScreen(username: 'abc', templateId: '128')),
                ).then((_) {
                  setState(() {
                    _isIconPressed = false;
                  });
                });
              },
          ),
        ],
      );
    } else {
      return PreferredSize(preferredSize: const Size(0, 0), child: Container());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), 
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Tab Navigation for Explore Recipe and What's in Your Kitchen
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Explore Recipe'),
                    Tab(text: "What's in Your Kitchen"),
                  ],
                  labelColor: customPurple, 
                  unselectedLabelColor: Colors.black, 
                  indicatorColor: customPurple,
                ),

                SizedBox(
                  height: 1850,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        children: [
                          //search recipe
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 20.0),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (query) {
                                _onSearchChanged(query);
                              },
                              decoration: InputDecoration(
                                labelText: 'Search Recipe...',
                                labelStyle: TextStyle(color: customPurple),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search,
                                  color: customPurple,),
                                  onPressed: _searchRecipe,
                                  
                                ),
                              ),
                            ),
                          ),

                          if (_suggestions.isNotEmpty)
  Positioned(
    top: 72,
    left: 16,
    right: 16,
    child: Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            // Access 'title' from the map at index
            var suggestion = _suggestions[index];  // Access the whole suggestion map

            return ListTile(
              title: Text(suggestion['title'] ?? 'No Title'),  // Access the title instead of id
  // Display the title of the suggestion
              onTap: () => _onSuggestionTap(_suggestions[index]),  // Pass the whole map to _onSuggestionTap
            );
          },
        ),
      ),
    ),
  ),


                          // Latest Recipes Section 
                           Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Our Latest Recipes',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                
                                // Add the "See All" button
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return AllRecipesScreen(recipes: _randomRecipes,
                                          initialLikeCounts: likeCounts,
                                          isLiked:isLiked,
                                          toggleLike: toggleLike,);
                                        },
                                      ),
                                    );
                                  },
                                  child: Text('See All',
                                    style: TextStyle(
                                      color: customPurple, // Set the text color to customPurple
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _isLoading? const CircularProgressIndicator() 
                              : Padding(
                                  padding: const EdgeInsets.only(left: 16.0), 
                                  child: SizedBox(
                                    height: 300, 
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal, 
                                      itemCount: _randomRecipes.length, 
                                      itemBuilder: (context, index) {
                                        final recipe = _randomRecipes[index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (!_recentlyViewed.any((item) =>item['id'] == recipe['id'])) {
                                                _recentlyViewed.insert(0,recipe); 
                                              }
                                            });
                                            // Navigate to the recipe details screen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>RecipeDetailScreen(recipeId: recipe['id']),
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            width:250, 
                                            child: Card(
                                              margin: const EdgeInsets.only(right: 16, bottom: 10),
                                              child: Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:const BorderRadius.only(
                                                          topLeft:Radius.circular(10),
                                                          topRight:Radius.circular(10),
                                                        ),
                                                        child: recipe['image'] !=null? Image.network(
                                                                recipe['image'],
                                                                height: 200,
                                                                width: 250,
                                                                fit: BoxFit.cover,
                                                                errorBuilder:
                                                                    (context,error,stackTrace) {
                                                                  return Container(
                                                                    height: 200,
                                                                    width: 250,
                                                                    color: Colors.grey, 
                                                                    child: const Icon(Icons.broken_image,
                                                                        size:60,
                                                                        color: Colors.white),
                                                                  );
                                                                },
                                                              )
                                                            : Container(
                                                                height: 200,
                                                                width: 250,
                                                                color: Colors.grey, 
                                                                child: const Icon(Icons.fastfood,
                                                                    size: 60,
                                                                    color: Colors.white),
                                                              ),
                                                      ),

                                                      // Time overlay in the top-left corner
                                                      Positioned(
                                                        top: 8,
                                                        left: 8,
                                                        child: Container(
                                                          padding:const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                                          decoration:BoxDecoration(
                                                            color: const Color.fromARGB(255,0,0,0).withOpacity(0.6),
                                                            borderRadius:BorderRadius.circular(5),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.timer,
                                                                  size: 14,
                                                                  color: Colors.white),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                recipe['readyInMinutes'] !=null
                                                                    ? '${recipe['readyInMinutes']} mins'
                                                                    : 'N/A',
                                                                style: const TextStyle(
                                                                    fontSize:12,
                                                                    color: Colors.white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      Positioned(
                                                        bottom: 8,
                                                        right: 8,
                                                        child: GestureDetector(
                                                          onTap: () => toggleLike(index), 
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(horizontal:8,vertical:4),
                                                            decoration:
                                                                BoxDecoration(color: Colors.black.withOpacity(0.6), // Keep background color unchanged
                                                              borderRadius:BorderRadius.circular(5),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.thumb_up,
                                                                  size: 14,
                                                                  color: isLiked[index]? const Color.fromARGB(255,93,167,199): Colors.white, // Change icon color based on the like state
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  '${likeCounts[index]}', 
                                                                  style: const TextStyle(
                                                                      fontSize:12,
                                                                      color: Colors.white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Recipe Title
                                                  Padding(
                                                    padding:const EdgeInsets.all(8.0),
                                                    child: Text(recipe['title'] ??'No Title', // Fallback for missing title
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:FontWeight.bold),
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

                          // Inside the Column in the body of your HomeScreen
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today\'s Recipe', 
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height:20), // Add some space between the title and the recipe
                                _isLoading
                                    ? const CircularProgressIndicator() // Show loading indicator while fetching data
                                    : GestureDetector(
                                        onTap: () {
                                          // Add the clicked recipe to recentlyViewed, avoiding duplicates
                                          setState(() {
                                            if (!_recentlyViewed.any((item) =>item['id'] ==_randomRecipes[9]['id'])) {
                                              _recentlyViewed.insert(0,_randomRecipes[9]); // Add to the start for most recent first
                                            }
                                          });
                                          // Navigate to the recipe details screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeDetailScreen(recipeId:_randomRecipes[9]['id']),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          height:300, // Adjust height as needed
                                          width: 400,
                                          child: Card(
                                            margin:const EdgeInsets.only(top: 10),
                                            child: Column(
                                              crossAxisAlignment:CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:const BorderRadius.only(
                                                        topLeft:Radius.circular(10),
                                                        topRight:Radius.circular(10),
                                                      ),
                                                      child: _randomRecipes.isNotEmpty && _randomRecipes[9]['image'] !=null
                                                          ? Image.network(_randomRecipes[9]['image'], // Use the first recipe image
                                                              height: 200,
                                                              width: 400,
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (context,error,stackTrace) {
                                                                return Container(
                                                                  height: 200,
                                                                  width: 400,
                                                                  color: Colors.grey, // Placeholder color for error
                                                                  child: const Icon(Icons.broken_image,
                                                                      size: 60,
                                                                      color: Colors.white),
                                                                );
                                                              },
                                                            )
                                                          : Container(
                                                              height: 200,
                                                              width: 400,
                                                              color: Colors.grey, // Default placeholder color
                                                              child: const Icon(
                                                                  Icons.fastfood,
                                                                  size: 60,
                                                                  color: Colors.white),
                                                            ),
                                                    ),
                                                    // Time overlay in the top-left corner
                                                    Positioned(
                                                      top: 8,
                                                      left: 8,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:BoxDecoration(
                                                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                                                          borderRadius:BorderRadius.circular(5),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.timer,
                                                                size: 14,
                                                                color: Colors.white),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              _randomRecipes.isNotEmpty &&_randomRecipes[0]['readyInMinutes'] !=null
                                                                  ? '${_randomRecipes[0]['readyInMinutes']} mins'
                                                                  : 'N/A',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors.white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // Favorite Icon (Like Button)
                                                    Positioned(
                                                      bottom: 8,
                                                      right: 8,
                                                      child: GestureDetector(
                                                        onTap: () => toggleLike(9), // Use index for "Today's Recipe" (0 in this case)
                                                        child: Container(
                                                          padding:const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                                          decoration:BoxDecoration(
                                                            color: Colors.black.withOpacity( 0.6),
                                                            borderRadius:BorderRadius.circular(5),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.thumb_up, // Thumbs-up icon
                                                                size: 14,
                                                                color: isLiked[9]? const Color.fromARGB(255,93,167,199)
                                                                    : Colors.white,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                '${likeCounts[9]}', // Like count for "Today's Recipe"
                                                                style: const TextStyle(
                                                                    fontSize:12,
                                                                    color: Colors.white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Recipe Title
                                                Padding(
                                                  padding:const EdgeInsets.all(8.0),
                                                  child: Text(_randomRecipes.isNotEmpty? _randomRecipes[9]['title'] ??'No Title'
                                                        : 'No Recipe Available',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                          // Quick Links For You Section
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Title
                                const Text(
                                  'Quick Links For You',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                    height: 20), // Space between title and tabs

                                // Horizontal Tabs for Meal Categories
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildClickableImage(
                                          'Breakfast', 'images/breakfast.jpg',_recentlyViewed),
                                      _buildClickableImage(
                                          'Lunch', 'images/lunch.jpg',_recentlyViewed),
                                      _buildClickableImage(
                                          'Dinner', 'images/dinner.jpg',_recentlyViewed),
                                      _buildClickableImage(
                                          'Dessert', 'images/dessert.jpg',_recentlyViewed),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          
                          // Title for Recently Viewed Foods
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start, // Align text to the left
                              children: [
                                Text(
                                  'Recently Viewed Foods',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(  height:  10),
                          _recentlyViewed.isEmpty
                              ? const Center(
                                  child: Text('No recently viewed foods'))
                              : Padding(
                                  padding: const EdgeInsets.only(left: 16.0), // Add padding
                                  child: SizedBox(
                                    height: 300, // Adjust height as needed
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                                      itemCount: _recentlyViewed.length,
                                      itemBuilder: (context, index) {
                                        final recipe = _recentlyViewed[index];

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>RecipeDetailScreen(recipeId: recipe['id']),
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            width:250, // Fixed width for the card
                                            child: Card(
                                              margin: const EdgeInsets.only(right: 16, bottom: 10),
                                              child: Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:const BorderRadius.only(
                                                          topLeft:Radius.circular(10),
                                                          topRight:Radius.circular(10),
                                                        ),
                                                        child: recipe['image'] !=null
                                                            ? Image.network(
                                                                recipe['image'],
                                                                height: 200,
                                                                width: 250,
                                                                fit: BoxFit.cover,
                                                                errorBuilder:
                                                                    (context,error,stackTrace) {
                                                                  return Container(
                                                                    height: 200,
                                                                    width: 250,
                                                                    color: Colors.grey,
                                                                    child:const Icon(
                                                                      Icons.broken_image,
                                                                      size: 60,
                                                                      color: Colors.white,
                                                                    ),
                                                                  );
                                                                },
                                                              )
                                                            : Container(
                                                                height: 200,
                                                                width: 250,
                                                                color:Colors.grey,
                                                                child:const Icon(
                                                                  Icons.fastfood,
                                                                  size: 60,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                      ),

                                                      // Time overlay
                                                      Positioned(
                                                        top: 8,
                                                        left: 8,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                                          decoration:BoxDecoration(
                                                            color: Colors.black.withOpacity(0.6),
                                                            borderRadius:BorderRadius.circular(5),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.timer,
                                                                size: 14,
                                                                color: Colors.white,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                recipe['readyInMinutes'] !=null
                                                                    ? '${recipe['readyInMinutes']} mins'
                                                                    : 'N/A',
                                                                style:const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      // Like overlay
                                                      Positioned(
                                                        bottom: 8,
                                                        right: 8,
                                                        child: GestureDetector(
                                                          onTap: () => toggleLike(index), // Toggle like
                                                          child: Container(
                                                            padding:const EdgeInsets.symmetric(horizontal: 8,vertical:4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.black.withOpacity( 0.6),
                                                              borderRadius:BorderRadius.circular( 5),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.thumb_up,
                                                                  size: 14,
                                                                  color: isLiked[index]
                                                                      ? const Color.fromARGB(255,93,167,199)
                                                                      : Colors.white, // Change based on state
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  '${likeCounts[index]}', // Display like count
                                                                  style: const TextStyle(
                                                                    fontSize:12,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  // Recipe Title
                                                  Padding(
                                                    padding:const EdgeInsets.all(8.0),
                                                    child: Text(recipe['title'] ?? 'No Title',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
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
        type:
            BottomNavigationBarType.fixed, // Ensures fixed positions for icons
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: customPurple, // Color for selected item
        // unselectedItemColor: Colors.black, // Color for unselected items
        selectedFontSize: 14, // Size of selected item's text
        unselectedFontSize: 12, // Size of unselected items' text
        iconSize: 28, // Uniform icon size
        showUnselectedLabels: true, // Keeps labels for unselected items
      ),
    );
  }

  Widget _buildClickableImage(String category, String imagePath,List _recentlyViewed) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () {
        // Navigate to the category screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(category: category,recentlyViewed: _recentlyViewed,),
          ),
        );
      },
      child: Container(
        width: 250, // Set width for the image container
        height: 300, // Set height for the image container
        margin: const EdgeInsets.only(right: 16), // Add spacing between items
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4), // Subtle shadow for depth
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16), // Match container corners
          child: Stack(
            children: [
              // Background Image
              Image.asset(
                imagePath,
                width: 250,
                height: 300,
                fit: BoxFit.cover,
              ),
              // Overlay Text
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
