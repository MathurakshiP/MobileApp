import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<dynamic> _categoryRecipes = [];
  bool _isLoading = false;
  Color customGreen = const Color.fromRGBO(20, 118, 21, 1.0);

  @override
  void initState() {
    super.initState();
    _fetchCategoryRecipes();
  }

  void _fetchCategoryRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await ApiService().fetchRecipesByCategory(widget.category);
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load recipes. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipeId: recipe['id']),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            recipe['image'] != null
                                ? Image.network(
                                    recipe['image'],
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey,
                                        child: const Icon(Icons.broken_image, size: 100, color: Colors.white),
                                      );
                                    },
                                  )
                                : Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: Colors.grey,
                                    child: const Icon(Icons.fastfood, size: 100, color: Colors.white),
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                recipe['title'] ?? 'No Title',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                              child: Text(
                                recipe['description'] ?? 'No description available',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
