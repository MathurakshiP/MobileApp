import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/Screens/home_screen.dart';
import 'package:mobile_app/auth.dart';

class GetStartedScreen extends StatelessWidget {
   const GetStartedScreen({super.key});

   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
          },
          child: const Text('Get Started'),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  
  LoginPage({super.key});

   final User? user =Auth().currentUser;

   Future<void>signOut() async{
    await Auth().signOut();
   }

  

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  String? errorMessage ='';
  bool isLogin =true;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();


  Future<void> signInWithEmailAndPassword() async{
    try{
      await Auth().signInWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text,);

    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async{
      try{
        await Auth().createUserWithEmailAndPassword(
          email: emailController.text, 
          password: passwordController.text,);

      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message;
        });
      }
    }

  // Widget _errorMessage(){
  //   return Text(errorMessage== '' ? '' : 'Humm ? $errorMessage');
  // }

 

  // Widget _loginOrRegisterButton(){
  //   return TextButton(
  //     onPressed: (){
  //       setState(() {
  //         isLogin =!isLogin;
  //       });
  //     },
  //     child: Text(isLogin? 'Register instead' : 'Login instead'),
  //   );
  // }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
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
                    color: isLogin ? Colors.green : Colors.grey,
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
                    color: isLogin ? Colors.grey : Colors.green,
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
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isLogin ? 100 : 200,
            child: ElevatedButton(
              onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),

          ),

          // Bottom button to navigate to HomeScreen
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to HomeScreen
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Adjust the color as needed
            ),
            child: const Text('Go to Home Screen'),
          ),
          
        ],
      ),
    ),
  );
}

}