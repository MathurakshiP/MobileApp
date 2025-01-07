import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_services.dart';

class MealPlanScreen extends StatefulWidget {
  final String username;
  final String templateId;

  MealPlanScreen({required this.username, required this.templateId});

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  late Future<Map<String, dynamic>> mealPlan;

  @override
  void initState() {
    super.initState();
    mealPlan = ApiService().getMealPlans(widget.username, widget.templateId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plan'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: mealPlan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No meal plan found.'));
          }

          final mealPlanData = snapshot.data!;
          final days = mealPlanData['days'];

          return ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final meals = day['items'];

              return Card(
                child: ListTile(
                  title: Text('Day ${day['day']}'),
                  subtitle: Column(
                    children: meals.map<Widget>((meal) {
                      return ListTile(
                        title: Text(meal['value']['title']),
                        leading: Image.network(
                          'https://spoonacular.com/cdn/ingredients_100x100/${meal['value']['imageType']}',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
