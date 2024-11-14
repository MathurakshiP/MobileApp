
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/get_started.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/auth.dart';


class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomeScreen(); // Redirect to home if user is logged in
        } else {
          return const GetStartedScreen(); // Redirect to GetStartedScreen if user is not logged in
        }
      },
    );
  }
}
