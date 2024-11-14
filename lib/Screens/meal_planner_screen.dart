import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:mobile_app/Services/api_services.dart'; // Import your ApiService

// ignore: must_be_immutable
class MealPlannerScreen extends StatelessWidget {
  Color customGreen = const Color.fromRGBO(20, 118, 21, 1.0);
  

  MealPlannerScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().fetchMealPlan(diet: 'any'), // Call the API function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No meal plan available.'));
          } else {
            final mealPlan = snapshot.data!;

            // Assuming the API returns a list of meals or meal details
            final meals = mealPlan['meals'] ?? []; // Adjust this based on your API response

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Meal Plan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(meal['title'] ?? 'No title'),
                            subtitle: Text(meal['description'] ?? 'No description'),
                            trailing: const Icon(Icons.add),
                            onTap: () {
                              // Action to add the meal to the planner or details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${meal['title']} to your plan'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add a new meal plan (could be a new screen or a dialog)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add a new meal plan')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
