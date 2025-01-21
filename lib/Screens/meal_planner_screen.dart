import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/addFoodScreen.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  final String userId;
  
  const MealPlannerScreen({super.key, required this.userId,});

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final Map<String, List<dynamic>> mealPlan = {
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
    "Saturday": [],
    "Sunday": [],
  };
  bool isMealPlan =true;
  List<String> selectedDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);
  bool isEditing = false;
  
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Plan your meal for a week',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            // Day selector
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                spacing: 18.0,
                children: mealPlan.keys.map((day) {
                  String dayAbbreviation = day.substring(0, 1); // First letter of the day
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedDays.contains(day)) {
                          selectedDays.remove(day);
                        } else {
                          selectedDays.add(day);
                        }
                      });
                    },
                    
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: selectedDays.contains(day)
                          ? selectedPurple
                          : Colors.grey.shade300,
                      child: Text(
                        dayAbbreviation,
                        style: TextStyle(
                          color: selectedDays.contains(day) ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 60),

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
                              setState(() {
                                mealPlan[day]!.add(newFood);
                              });
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
                                builder: (context) => RecipeDetailScreen(recipeId: food['id']),
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
                                    setState(() {
                                      mealPlan[day]!.remove(food);
                                    });
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

