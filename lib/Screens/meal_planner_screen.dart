import 'package:flutter/material.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlanScreen> {
  // Sample meal plan data structure
  Map<String, Map<String, String>> weeklyMealPlan = {
    'Monday': {'Breakfast': '', 'Lunch': '', 'Dinner': '', 'Snacks': ''},
    'Tuesday': {'Breakfast': '', 'Lunch': '', 'Dinner': '', 'Snacks': ''},
    'Wednesday': {'Breakfast': '', 'Lunch': '', 'Dinner': '', 'Snacks': ''},
    'Thursday': {'Breakfast': '', 'Lunch': '', 'Dinner': '', 'Snacks': ''},
    'Friday': {'Breakfast': '', 'Lunch': '', 'Dinner': '', 'Snacks': ''},
    'Saturday': {'Breakfast': '', 'Lunch': '', 'Dinner': '', 'Snacks': ''},
    'Sunday': {'Breakfast': '', 'Lunch': '', 'Dinner': '', 'Snacks': ''},
  };

  String selectedDay = 'Monday';

  // Controller to handle meal input
  TextEditingController mealController = TextEditingController();

  void _openMealInputDialog(String mealType) {
    mealController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $mealType'),
        content: TextField(
          controller: mealController,
          decoration: InputDecoration(hintText: 'Enter meal details'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                weeklyMealPlan[selectedDay]?[mealType] = mealController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealEntry(String mealType) {
    return ListTile(
      title: Text(mealType),
      subtitle: Text(weeklyMealPlan[selectedDay]?[mealType] ?? ''),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () => _openMealInputDialog(mealType),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: weeklyMealPlan.keys.map((day) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = day;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: selectedDay == day ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: selectedDay == day ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Meal Planner'),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          _buildDaySelector(),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildMealEntry('Breakfast'),
                _buildMealEntry('Lunch'),
                _buildMealEntry('Dinner'),
                _buildMealEntry('Snacks'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Optional: Save weekly meal plan data here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Meal Plan Saved')),
                );
              },
              child: Text('Save Meal Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
