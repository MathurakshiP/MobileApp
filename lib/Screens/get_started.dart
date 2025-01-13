import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/auth.dart';

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
                          MaterialPageRoute(builder: (_) => LoginPage()),
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLogin = true;
  bool isPasswordVisible = false;

  String? errorMessage;

  Future<void> signInWithEmailAndPassword() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showErrorSnackbar('Email and Password cannot be empty');
      return;
    }

    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      showErrorSnackbar(e.message ?? 'Error occurred while signing in');
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      showErrorSnackbar('All fields are required');
      return;
    }

    try {
      final userCredential = await Auth().createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await userCredential.user!.updateDisplayName(nameController.text.trim());
      setState(() => isLogin = true); // Switch to Login view
      clearTextFields();
      showSuccessSnackbar('Account created successfully! Please log in.');
    } on FirebaseAuthException catch (e) {
      showErrorSnackbar(e.message ?? 'Error occurred while signing up');
    }
  }

  void clearTextFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.green))),
    );
  }

  Widget buildTextField({
    required String labelText,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: suffixIcon,
        ),
      ),
    );
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
                        color: isLogin ? Colors.purple : Colors.grey,
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
                        color: isLogin ? Colors.grey : Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isLogin)
                buildTextField(
                  labelText: 'Name',
                  controller: nameController,
                ),
              buildTextField(
                labelText: 'Email',
                controller: emailController,
              ),
              buildTextField(
                labelText: 'Password',
                controller: passwordController,
                obscureText: !isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => isPasswordVisible = !isPasswordVisible),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLogin
                    ? signInWithEmailAndPassword
                    : createUserWithEmailAndPassword,
                child: Text(isLogin ? 'Login' : 'Sign Up'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text('Do it Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  