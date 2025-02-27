import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/Screens/addFoodScreen.dart';
import 'package:mobile_app/Screens/premiumPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';
import 'package:mobile_app/Screens/signUpReminderScreen.dart';

class MealPlannerScreen extends StatefulWidget {
  final String userId;

  const MealPlannerScreen({super.key, required this.userId});

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, List<dynamic>>> mealPlan = {
    "Monday": {
    "Breakfast": [],
    "Lunch": [],
    "Dinner": [], "Salad":[],"Soup":[],"Dessert":[],
  },
  "Tuesday": {
    "Breakfast": [],
    "Lunch": [],
    "Dinner": [],"Salad":[],"Soup":[],"Dessert":[],
  },
  "Wednesday": {
    "Breakfast": [],
    "Lunch": [],
    "Dinner": [],"Salad":[],"Soup":[],"Dessert":[],
  },
  "Thursday": {
    "Breakfast": [],
    "Lunch": [],
    "Dinner": [],"Salad":[],"Soup":[],"Dessert":[],
  },
  "Friday": {
    "Breakfast": [],
    "Lunch": [],
    "Dinner": [],"Salad":[],"Soup":[],"Dessert":[],
  },
  "Saturday": {
    "Breakfast": [],
    "Lunch": [],
    "Dinner": [],"Salad":[],"Soup":[],"Dessert":[],
  },
  "Sunday": {
    "Breakfast": [],
    "Lunch": [],
    "Dinner": [],"Salad":[],"Soup":[],"Dessert":[],
  },
  };

  List<String> correctOrder = ["M", "T", "W", "T", "F", "S", "S"];
  bool isMealPlan = true;
  List<String> selectedDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);
  bool isEditing = false;
  late List<String> sortedKeys;
  late String currentWeekRange;

  DateTime _currentDate = DateTime.now();
  DateTime? _startOfWeek;
  DateTime? _endOfWeek;

  @override
  void initState() {
    super.initState();
    _calculateCurrentWeekRange();
    _loadMealPlan();  // Call to load the meal plan from Firestore
    sortedKeys = mealPlan.keys.toList()
      ..sort((a, b) => correctOrder.indexOf(a.substring(0, 3)).compareTo(correctOrder.indexOf(b.substring(0, 3))));
  }

  // Load meal plan for the current week
  void _loadMealPlan() async {
    try {
      DocumentSnapshot weeklyPlanDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('mealPlanner')
          .doc(currentWeekRange)
          .get();

      if (weeklyPlanDoc.exists) {
        Map<String, dynamic> data = weeklyPlanDoc.data() as Map<String, dynamic>;
        setState(() {
          mealPlan = {
            for (var day in data.keys)
              day: {
                "Breakfast": List<Map<String, dynamic>>.from(data[day]["Breakfast"] ?? []),
                "Lunch": List<Map<String, dynamic>>.from(data[day]["Lunch"] ?? []),
                "Dinner": List<Map<String, dynamic>>.from(data[day]["Dinner"] ?? []),
                "Salad": List<Map<String, dynamic>>.from(data[day]["Salad"] ?? []),
                "Soup": List<Map<String, dynamic>>.from(data[day]["Soup"] ?? []),
                "Dessert": List<Map<String, dynamic>>.from(data[day]["Dessert"] ?? []),
              }
          };
        });
      } else {
        // If no data exists for the week, load the default empty meal plan
        setState(() {
          mealPlan = {
            "Monday": {
              "Breakfast": [],
              "Lunch": [],
              "Dinner": [],
              "Salad": [],
              "Soup": [],
              "Dessert": [],
            },
            "Tuesday": {
              "Breakfast": [],
              "Lunch": [],
              "Dinner": [],
              "Salad": [],
              "Soup": [],
              "Dessert": [],
            },
            "Wednesday": {
              "Breakfast": [],
              "Lunch": [],
              "Dinner": [],
              "Salad": [],
              "Soup": [],
              "Dessert": [],
            },
            "Thursday": {
              "Breakfast": [],
              "Lunch": [],
              "Dinner": [],
              "Salad": [],
              "Soup": [],
              "Dessert": [],
            },
            "Friday": {
              "Breakfast": [],
              "Lunch": [],
              "Dinner": [],
              "Salad": [],
              "Soup": [],
              "Dessert": [],
            },
            "Saturday": {
              "Breakfast": [],
              "Lunch": [],
              "Dinner": [],
              "Salad": [],
              "Soup": [],
              "Dessert": [],
            },
            "Sunday": {
              "Breakfast": [],
              "Lunch": [],
              "Dinner": [],
              "Salad": [],
              "Soup": [],
              "Dessert": [],
            },
          };
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading meal plan: $e');
      }
    }
  }

  // Save the meal plan for the current week
  void _saveMealPlan() async {
    try {
      // Save the weekly plan
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('mealPlanner')
          .doc(currentWeekRange)
          .set(mealPlan);

      // Save daily meal plans
      for (String day in mealPlan.keys) {
        CollectionReference dailyCollection = _firestore
            .collection('users')
            .doc(widget.userId)
            .collection('mealPlanner')
            .doc(currentWeekRange)
            .collection(day);

        // Clear existing meals for the day
        QuerySnapshot existingMeals = await dailyCollection.get();
        for (QueryDocumentSnapshot doc in existingMeals.docs) {
          await doc.reference.delete();
        }

        // Add updated meals for the day, categorized by Breakfast, Lunch, Dinner, etc.
        for (String category in ["Breakfast", "Lunch", "Dinner", "Salad", "Soup", "Dessert"]) {
          for (Map<String, dynamic> meal in mealPlan[day]?[category] ?? []) {
            String mealId = "${DateTime.now().millisecondsSinceEpoch}";
            await dailyCollection
                .doc(mealId)
                .set({
                  'mealId': mealId,
                  'category': category,
                  'name': meal['name'],
                  'ingredients': meal['ingredients'],
                  'recipe': meal['recipe'],
                });
          }
        }
      }
    } catch (e) {
      print('Error saving meal plan: $e');
    }
  }
  /// Add a meal to the plan and save
  void _addMeal(String day, Map<String, dynamic> food,String category) {
    setState(() {
      mealPlan[day]![category]!.add(food);
    });
    _saveMealPlan();
  }

  /// Remove a meal from the plan and save
  void _removeMeal(String day, Map<String, dynamic> food,String category) {
    setState(() {
      mealPlan[day]![category]!.remove(food);
    });
    _saveMealPlan();
  }

  // Function to calculate the start and end of the current week
  // Calculate current week range (e.g., "Feb 24 to Mar 02")
  void _calculateCurrentWeekRange() {
    final DateTime now = _currentDate;
    final int currentWeekday = now.weekday;

    _startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    _endOfWeek = _startOfWeek!.add(Duration(days: 6));

    setState(() {
      currentWeekRange = "${DateFormat('MMM dd').format(_startOfWeek!)} to ${DateFormat('MMM dd').format(_endOfWeek!)}";
    });
  }

  // Function to format date as a string
  String formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  // Function to move to the next week
  void _nextWeek() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 7));
      _calculateCurrentWeekRange();
    });
  }

  // Function to move to the previous week
  void _previousWeek() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 7));
      _calculateCurrentWeekRange();
    });
  }

  // Update the week and reload the meal plan for the new week
  void _changeWeek(int direction) {
    // direction: -1 for previous week, 1 for next week
    setState(() {
      _startOfWeek = _startOfWeek!.add(Duration(days: 7 * direction));
      _endOfWeek = _endOfWeek!.add(Duration(days: 7 * direction));
      currentWeekRange = "${DateFormat('MMM dd').format(_startOfWeek!)} to ${DateFormat('MMM dd').format(_endOfWeek!)}";
    });

    // Reload the meal plan for the new week
    _loadMealPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Planner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          // Edit button to toggle edit mode
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week range box with current week and navigation buttons
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: selectedPurple,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.grey.withOpacity(1), spreadRadius: 2)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          _previousWeek;
                        _changeWeek(-1); 
                        }
                      ),
                      Text(
                        _startOfWeek != null && _endOfWeek != null
                            ? (_currentDate.isAtSameMomentAs(_startOfWeek!) || // Current date is the start of the week
                                (_currentDate.isAfter(_startOfWeek!) && _currentDate.isBefore(_endOfWeek!.add(const Duration(days: 1)))))
                              ? '${formatDate(_startOfWeek!)} - ${formatDate(_endOfWeek!)}' // Show "This Week" if within the current week
                              : '${formatDate(_startOfWeek!)} - ${formatDate(_endOfWeek!)}' // Otherwise, show week range
                            : '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          _nextWeek;
                        _changeWeek(1); 
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      spacing: 7.0,
                      
                      children: sortedKeys.map((day) {
                        String dayAbbreviation = day.substring(0, 3); // First letter of the day
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedDays.contains(day)) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                              // Sort selectedDays based on predefined week order
                              selectedDays.sort((a, b) {
                                List<String> weekOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
                                return weekOrder.indexOf(a).compareTo(weekOrder.indexOf(b));
                              });
                            });
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: selectedDays.contains(day)
                                ? Colors.white
                                : selectedPurple,
                            child: Text(
                              dayAbbreviation,
                              style: TextStyle(
                                color: selectedDays.contains(day) ? Colors.black : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Show a dialog or navigate to the premium page
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Get Premium'),
                            content: const Text(
                              'Unlock customized meal plan templates and more by upgrading to Premium!',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                  // Navigate to the premium subscription page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PremiumPage(),
                                    ),
                                  );
                                },
                                child: const Text('Get Premium'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      backgroundColor: const Color.fromARGB(255, 239, 231, 241), // Customize button color
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Start Your Plan'),
                  ),
                ],
              ),
            ),

            // Meal plan list for selected days        
            ...selectedDays.map((day) {
              // Get the categories under the selected day
              Map<String, List<dynamic>> categories = mealPlan[day]!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day header row with "Add" button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddFoodScreen(userId: widget.userId),
                              ),
                            );
                            if (result != null) {
                              final selectedFood = result['food']; // Get the selected food
                              final selectedCategory = result['category']; // Get the selected category
                              if (selectedFood != null && selectedCategory != null) {
                                _addMeal(day, selectedFood, selectedCategory); // Add meal with both food and category
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    
                    // Iterate over categories (Breakfast, Lunch, Dinner)
                    ...categories.keys.map((category) {
                      List<dynamic> foods = categories[category]!;

                      // Only display the category if it has food
                      if (foods.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Header (Breakfast, Lunch, Dinner) with indentation
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0), // Indentation from the left
                                  child: Text(
                                    category, // Category name (Breakfast, Lunch, Dinner)
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            // Food items under each category
                            ...foods.map((food) => Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to the RecipeDetailsScreen when the food is tapped
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(
                                        recipeId: food['id'], 
                                        isMealPlan: isMealPlan,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display the food image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0), // Rounded corners for the image
                                      child: Image.network(
                                        food['image'], // URL for the food image
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12), // Spacing between the image and text
                                    // Display the food name
                                    Expanded(
                                      child: Text(
                                        food['title'], // Name of the food
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    if (isEditing)
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _removeMeal(day, food, category);
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            )),
                            const Divider(),
                          ],
                        );
                      } else {
                        return SizedBox.shrink(); // Do not display an empty category
                      }
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

extension DateTimeWeek on DateTime {
  int get weekOfYear {
    var firstDayOfYear = DateTime(this.year, 1, 1);
    var days = this.difference(firstDayOfYear).inDays;
    return (days / 7).floor() + 1;
  }
}
