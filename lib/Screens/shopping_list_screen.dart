import 'package:flutter/material.dart';
import 'package:mobile_app/providers/shopping_list_provider.dart';
//import 'package:mobile_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
// import 'package:mobile_app/providers/shopping_list_provider.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access shopping list from the provider
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    final shoppingList = shoppingListProvider.shoppingList;
    Color customGreen = const Color.fromARGB(255, 96, 26, 182);
//final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List',style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white,
                fontSize: 20,),
        ),
        backgroundColor: customGreen,
        automaticallyImplyLeading: false, // Prevents the back arrow from appearing
        
      ),
      body: shoppingList.isNotEmpty
          ? ListView.builder(
              itemCount: shoppingList.length,
              itemBuilder: (context, index) {
                final item = shoppingList[index];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      shoppingListProvider.removeItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$item removed from shopping list')),
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text('No items in your shopping list!'),
            ),
    );
  }
}
