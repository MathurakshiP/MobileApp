import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/Screens/login_page.dart';

//import 'package:mobile_app/providers/theme_provider.dart';
//import 'package:provider/provider.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);
    //final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      body: Stack(
        children: [
          // Background design
          // Positioned(
          //   top: -180,
          //   left: 230,
          //   child: Transform(
          //     transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.74),
          //     child: Container(
          //       width: 500,
          //       height: 440,
          //       decoration: ShapeDecoration(
          //         color: const Color(0xFFD9D9D9),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(123),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            top: 0,
            left: -250,
            child: Transform(
              transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0),
              child: ClipPath(
                clipper: CustomClipperPath(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 2.2,
                  height: 1000,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/egg4.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Positioned(
          //   left: 108.78,
          //   top: -230.90,
          //   child: Transform(
          //     transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.74),
          //     child: Container(
          //       width: 596.38,
          //       height: 398.84,
          //       decoration: ShapeDecoration(
          //         color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.20000000298023224),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(110),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Logo and content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30), // Adjust the logo's position
                    child: Image.asset(
                      'images/cookify2.png', // Replace with your logo
                      height: 350,
                      width: 350,
                    ),
                  ),
                ),
              ),
              // Bottom button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    // Get Started button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 40),
                        backgroundColor:const Color.fromARGB(255, 96, 26, 182),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Inika',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomClipperPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(100), // Apply the same border radius as in the original shape
      ),
    );
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}