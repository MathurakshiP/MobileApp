import 'package:firebase_auth/firebase_auth.dart';


class Auth {
  final FirebaseAuth _firebaseAuth =FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,

  })async{
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,);
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,

  })async{
    // Return the UserCredential to the caller
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateDisplayName(String displayName) async {
  final user = _firebaseAuth.currentUser;
  if (user != null) {
    await user.updateDisplayName(displayName);
    await user.reload(); // Ensure the change is reflected
  }
}


  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }
}