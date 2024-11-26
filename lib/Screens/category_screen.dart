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
  Color customGreen = const Color.fromRGBO(20, 118, 21, 1.0);

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
      final recipes = await ApiService().fetchRelatedRecipes(715538); // Update this ID if needed
      setState(() {
        _categoryRecipes = recipes;
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
        backgroundColor: customGreen,
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
                              // errorBuilder: (context, error, stackTrace) {
                              //   return Container(
                              //     height: 50,
                              //     width: 50,
                              //     color: Colors.grey,
                              //     child: const Icon(Icons.broken_image, size: 30, color: Colors.white),
                              //   );
                              // },
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
                      subtitle: Text(
                        recipe['description'] ?? 'No description available',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
