// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/src/dotenv.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:mobile_app/Screens/get_started.dart';
// import 'package:mobile_app/Screens/home_screen.dart';
// import 'package:mobile_app/Screens/profile_screen.dart';
import 'package:mobile_app/Screens/widget_tree.dart';
import 'package:mobile_app/providers/shopping_list_provider.dart';
import 'package:provider/provider.dart';
import 'providers/saved_food_provider.dart';
import 'providers/theme_provider.dart';
// import 'package:mobile_app/services/api_services.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // await dotenv.load(fileName: ".env");
  // print(dotenv.env);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavedFoodProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Recipe App',
            theme: themeProvider.currentTheme, // Apply the current theme
            home: const WidgetTree(),
            // initialRoute: '/home',
            // routes: {
            //   '/': (context) => LoginPage(),
            //   '/home': (context) => ProfileScreen(),
            // },
          );
        },
      ),
    );
  }
}
