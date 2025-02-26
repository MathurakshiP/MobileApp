import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
 final bool isMealPlan;
  final String userId;
  const CategoryScreen({super.key, required this.category,required this.userId, required this.isMealPlan});
 
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
    'Asian',
    'Chinese',
    'Indian',
    'Italian',
    'Japanese',
    'Mexican',
    'Thai',
  ];

  List<String> times = [
    'Max 15 minutes',
    'Max 30 minutes',
    'Max 60 minutes',
    'More than 60 minutes',
  ];

  @override
  void initState() {
    super.initState();
    fetchRecentlyViewed(); // Fetch recently viewed recipes
    fetchAllRecipes(); // Fetch all recipes by default
    fetchAllRecipes(); // Fetch all recipes by default
  }

// Firestore instance
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// `recentlyViewed` state variable
List<dynamic> _recentlyViewed = [];

// Fetch `recentlyViewed` from Firestore for the specific user
void fetchRecentlyViewed() async {
  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('recently_viewed')
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _recentlyViewed = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error fetching recently viewed: $error');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load recently viewed recipes.')),
    );
  }
}

// Update `recentlyViewed` in Firestore (under subcollection `recently_viewed`)
void updateRecentlyViewed(Map<String, dynamic> recipe) async {
  try {
    // Check if the recipe already exists in the recently viewed list
    final docRef = _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('recently_viewed')
        .doc(recipe['id']); // Using the recipe's ID as the document ID

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // Add the recipe to Firestore if it's not already in the list
      await docRef.set(recipe);

      setState(() {
        // Add to local list, but maintain the most recent at the top
        _recentlyViewed.insert(0, recipe);
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error updating recently viewed: $error');
    }
  }
}

  String selectedCategory(String category){
    if(category =='Breakfast') {
      return 'breakfast';
    } else if(category =='Lunch') {
      return 'main course';
    } else if(category =='Dinner') {
      return 'main course';
    }else if(category =='Dessert') {
      return 'dessert';
    } else if(category =='Salad') {
      return 'salad';
    }else if(category =='Soup') {
      return 'soup';
    }else {
      return 'main course';
    }
    
  }
  // Fetch all recipes for the category using AllCategory API
  void fetchAllRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await ApiService().allcategory(selectedCategory(widget.category), 20);
      setState(() {
        _categoryRecipes = recipes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching all recipes for category ${widget.category}: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load recipes. Please try again later.')),
      );
    }
  }

  // Fetch filtered recipes for the category using OneCategory API
  void fetchFilteredRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Determine max ready time based on selected time filter
      int maxReadyTime = 0; // Default: no limit
      if (_selectedTime == 'Max 15 minutes') {
        maxReadyTime = 15;
      } else if (_selectedTime == 'Max 30 minutes') {
        maxReadyTime = 30;
      } else if (_selectedTime == 'Max 60 minutes') {
        maxReadyTime = 60;
      } else if (_selectedTime == 'More than 60 minutes') {
        maxReadyTime = 500; // Example: Arbitrary high limit for "More than 60 minutes"
      }

      // Use selected cuisine or fallback to category
      final cuisine = _selectedCuisine == 'Any' || _selectedCuisine == null
          ? widget.category
          : _selectedCuisine!;

      final recipes = await ApiService().onecategory(cuisine, selectedCategory(widget.category), maxReadyTime, 10);
      setState(() {
        _categoryRecipes = recipes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching filtered recipes for category ${widget.category}: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load recipes. Please try again later.')),
      );
    }
  }

  // Apply filters and decide which API to call
  void _applyFilters() {
    if ((_selectedCuisine == null || _selectedCuisine == 'Any') &&
        (_selectedTime == null || _selectedTime == 'Any')) {
      fetchAllRecipes(); // Fetch all recipes
    } else {
      fetchFilteredRecipes(); // Fetch filtered recipes
    }
    Navigator.pop(context); // Close the filter modal
  }

  void addToMealPlanner(Map<String, dynamic> recipe)  {
    Navigator.pop(context, recipe);
}

void _navigateToReceipeDetails(Map<String, dynamic> recipe) async {
    final selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(recipeId: recipe['id'],isMealPlan:widget.isMealPlan),
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
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        backgroundColor: customPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      // Ensure that the dropdowns are updated based on the selected values
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [ 
                // Centered Dropdowns
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: DropdownButton<String>(
                            isExpanded: true, // Ensure it takes full width
                            isDense: true,
                            hint: const Text('Select Cuisine'),
                            value: _selectedCuisine,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCuisine = newValue;
                              });
                            },
                            items: ['Any', ...cuisines]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Space between dropdowns
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: DropdownButton<String>(
                            isExpanded: true, // Ensure it takes full width
                            isDense: true,
                            hint: const Text('Select Time'),
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16), // Space above button
                ElevatedButton(
                  onPressed: () {
                    _applyFilters(); // Apply the filters
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
},


          ),
        ],
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _categoryRecipes.isEmpty
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
                            child: const Icon(Icons.broken_image,
                                size: 30, color: Colors.white),
                          );
                        },
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.fastfood,
                            size: 30, color: Colors.white),
                      ),
                title: Text(
                  recipe['title'] ?? 'No Title',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: widget.isMealPlan
                    ? IconButton( 
                        icon: const Icon(Icons.add, color: Color.fromARGB(255, 96, 26, 182)),
                        onPressed: () {
                          // Add recipe to meal planner
                          addToMealPlanner(recipe); // Implement this function to handle meal planner logic
                        },
                      )
                    : null,
                onTap: () {
                  updateRecentlyViewed(recipe); // Update Firestore with the viewed recipe
                  
                  _navigateToReceipeDetails(recipe);
                },
              );
            },
          ),

    );
  }
}
