import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/addFoodScreen.dart';

class MealPlannerScreen extends StatefulWidget {
  final String userId;
  
  const MealPlannerScreen({super.key, required this.userId,});

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final Map<String, List<String>> mealPlan = {
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
              List<String> foods = mealPlan[day]!;

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
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Text(
                            food,
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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

