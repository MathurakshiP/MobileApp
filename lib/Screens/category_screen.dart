import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<dynamic> _categoryRecipes = [];
  bool _isLoading = false;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  @override
  void initState() {
    super.initState();
    fetchRelatedRecipes();
  }

  // Fetch related recipes for the category
  void fetchRelatedRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await ApiService().fetchRandomRecipes(); // Update this ID if needed
      List<dynamic> filteredRecipes = [];
      for (var recipe in recipes) {
        final String lunch ="lunch";
        final String breakfast ="breakfast";
        final String dinner ="dinner";
        final String dessert ="dessert";
        if (recipe['dishTypes'] != null ) {
          if(widget.category=="Breakfast"){
              if (recipe['dishTypes'].contains(breakfast)) {
                filteredRecipes.add(recipe);
              }
          }
          else if(widget.category == "Lunch"){
            if (recipe['dishTypes'].contains(lunch)) {
              filteredRecipes.add(recipe);
            }
          }
          else if(widget.category == "Dinner"){
            if (recipe['dishTypes'].contains(dinner)) {
              filteredRecipes.add(recipe);
            }
          }
          else if(widget.category == "Dessert"){
            if (recipe['dishTypes'].contains(dessert)) {
              filteredRecipes.add(recipe);
            }
          }

          
  }
      }
      setState(() {
        _categoryRecipes = filteredRecipes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching recipes for category ${widget.category}: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load recipes. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category, style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white, 
          fontSize: 20,
        )),
        backgroundColor: customPurple,
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
                                  child: const Icon(Icons.broken_image, size: 30, color: Colors.white),
                                );
                              },
                            )
                          : Container(
                              height: 50,
                              width: 50,
                              color: Colors.grey,
                              child: const Icon(Icons.fastfood, size: 30, color: Colors.white),
                            ),
                      title: Text(
                        recipe['title'] ?? 'No Title',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipeId: recipe['id']),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
