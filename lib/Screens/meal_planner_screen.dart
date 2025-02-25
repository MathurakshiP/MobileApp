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
  Map<String, List<dynamic>> mealPlan = {
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
    "Saturday": [],
    "Sunday": [],
  };

  List<String> correctOrder = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  bool isMealPlan = true;
  List<String> selectedDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);
  bool isEditing = false;
  late List<String> sortedKeys;

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

  /// Load meal plan from Firebase
  void _loadMealPlan() async {
    try {
      DocumentSnapshot weeklyPlanDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('mealPlanner')
          .doc('weeklyPlan')
          .get();

      if (weeklyPlanDoc.exists) {
        Map<String, dynamic> data = weeklyPlanDoc.data() as Map<String, dynamic>;
        setState(() {
          mealPlan = {
            for (var key in data.keys) key: List<Map<String, dynamic>>.from(data[key])
          };
        });
      }

      // Load daily meal plans
      for (String day in mealPlan.keys) {
        QuerySnapshot dailyMeals = await _firestore
            .collection('users')
            .doc(widget.userId)
            .collection('mealPlanner')
            .doc('weeklyPlan')
            .collection(day)
            .get();

        setState(() {
          mealPlan[day] = dailyMeals.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading meal plan: $e');
      }
    }
  }

  /// Save meal plan to Firebase
  void _saveMealPlan() async {
    try {
      // Save weekly plan
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('mealPlanner')
          .doc('weeklyPlan')
          .set(mealPlan);

      // Save daily meal plans
      for (String day in mealPlan.keys) {
        CollectionReference dailyCollection = _firestore
            .collection('users')
            .doc(widget.userId)
            .collection('mealPlanner')
            .doc('weeklyPlan')
            .collection(day);

        // Clear existing meals for the day
        QuerySnapshot existingMeals = await dailyCollection.get();
        for (QueryDocumentSnapshot doc in existingMeals.docs) {
          await doc.reference.delete();
        }

        // Add updated meals for the day
        for (Map<String, dynamic> meal in mealPlan[day]!) {
          await dailyCollection.add(meal);
        }
      }
    } catch (e) {
      print('Error saving meal plan: $e');
    }
  }

  /// Add a meal to the plan and save
  void _addMeal(String day, Map<String, dynamic> food) {
    setState(() {
      mealPlan[day]!.add(food);
    });
    _saveMealPlan();
  }

  /// Remove a meal from the plan and save
  void _removeMeal(String day, Map<String, dynamic> food) {
    setState(() {
      mealPlan[day]!.remove(food);
    });
    _saveMealPlan();
  }

  // Function to calculate the start and end of the current week
  void _calculateCurrentWeekRange() {
    final DateTime now = _currentDate;
    final int currentWeekday = now.weekday;

    _startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    _endOfWeek = _startOfWeek!.add(Duration(days: 6));

    setState(() {});
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
                        onPressed: _previousWeek,
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
                        onPressed: _nextWeek,
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
                                      builder: (context) => SignUpReminderPage(),
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
              List<dynamic> foods = mealPlan[day]!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            final newFood = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddFoodScreen(userId: widget.userId),
                              ),
                            );
                            if (newFood != null) {
                              _addMeal(day, newFood);
                            }
                          },
                        ),
                      ],
                    ),
                    ...foods.map((food) => Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the RecipeDetailsScreen when the food is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipeId: food['id'], isMealPlan: isMealPlan),
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
                                  _removeMeal(day, food);
                                },
                              ),
                          ],
                        ),
                      ),
                    )),
                    const Divider(),
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