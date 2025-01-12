import 'package:flutter/material.dart';

class AllRecipesScreen extends StatefulWidget {
  final List<dynamic> recipes;
  final List<int> initialLikeCounts; // Like counts passed from HomeScreen

  // Constructor to receive recipes and initial like counts
  AllRecipesScreen({required this.recipes, required this.initialLikeCounts});

  @override
  _AllRecipesScreenState createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen> {
  late List<int> likeCounts;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  @override
  void initState() {
    super.initState();
    // Initialize likeCounts with the initial like counts passed from HomeScreen
    likeCounts = List.from(widget.initialLikeCounts);
  }

  // Update the like count when the like button is pressed
  void toggleLike(int index) {
    setState(() {
      // Toggle the like status (increase or decrease the like count)
      likeCounts[index]++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Latest Recipes',style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white, 
          fontSize: 20,
        )),
        backgroundColor: customPurple, // Color for AppBar
      ),
      body: widget.recipes.isEmpty
          ? const Center(child: Text('No recipes available.'))
          : ListView.builder(
              itemCount: widget.recipes.length,
              itemBuilder: (context, index) {
                final recipe = widget.recipes[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Gaps between items
                  child: SizedBox(
                    height: 300, // Adjust height as needed
                    child: Card(
                      margin: const EdgeInsets.only(top: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with curved border and time overlay
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: recipe['image'] != null
                                    ? Image.network(
                                        recipe['image'], // Use recipe image
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: Colors.grey, // Placeholder color for error
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey, // Default placeholder color
                                        child: const Icon(
                                          Icons.fastfood,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              // Time overlay in the top-left corner
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 0, 0, 0)
                                        .withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer,
                                          size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        recipe['readyInMinutes'] != null
                                            ? '${recipe['readyInMinutes']} mins'
                                            : 'N/A',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Favorite Icon (Like Button)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => toggleLike(index), // Pass index here
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up, // Thumbs-up icon
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${likeCounts[index]}', // Like count
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Recipe Title
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recipe['title'] ?? 'No Title',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
