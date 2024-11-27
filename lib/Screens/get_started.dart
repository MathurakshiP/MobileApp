import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/auth.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      body: Stack(
        children: [
          // Background design
          Positioned(
            top: -180,
            left: 230,
            child: Transform(
              transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.74),
              child: Container(
                width: 500,
                height: 440,
                decoration: ShapeDecoration(
                  color: const Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(123),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -130,
            left: 370,
            child: Transform(
              transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.38),
              child: ClipPath(
                clipper: CustomClipperPath(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.3,
                  height: 430,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/pic.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 108.78,
            top: -230.90,
            child: Transform(
              transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.74),
              child: Container(
                width: 596.38,
                height: 398.84,
                decoration: ShapeDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.20000000298023224),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(110),
                  ),
                ),
              ),
            ),
          ),
          // Logo and content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 400), // Adjust the logo's position
                    child: Image.asset(
                      'images/cookify.png', // Replace with your logo
                      height: 300,
                      width: 300,
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
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 40),
                        backgroundColor: const Color(0xCC147615),
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
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Redirect to Login Page after successful sign up
      setState(() {
        isLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isLogin = true),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLogin ? const Color(0xCC147615) : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => setState(() => isLogin = false),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLogin ? Colors.grey : const Color(0xCC147615),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isLogin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ),
              if (errorMessage != '')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isLogin ? 150 : 150,
                child: ElevatedButton(
                  onPressed: isLogin
                      ? signInWithEmailAndPassword
                      : createUserWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xCC147615),
                  ),
                  child: Text(
                    isLogin ? 'Login' : 'Sign Up',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(204, 255, 255, 255),
                    ),
                  ),
                ),
              ),
              // Bottom button to navigate to HomeScreen or "Do it later"
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate directly to Home Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 90, 165, 103),
                ),
                child: const Text(
                  'Do it Later',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(204, 255, 255, 255),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  