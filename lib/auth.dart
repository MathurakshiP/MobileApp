import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in user with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create new user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // After user is created, save additional user data to Firestore
    await _saveUserData(userCredential.user);

    return userCredential;
  }

  // Save user data to Firestore (called after user creation)
  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      // Create a document in Firestore with the user's UID
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName ?? '',
      });
    }
  }

  // Update display name in Firebase Authentication and Firestore
  Future<void> updateDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload(); // Ensure the change is reflected
      await _updateUserDataInFirestore(user);
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserDataInFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'name': user.displayName ?? '',
    });
  }

  // Update password in Firebase Authentication
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        await user.reload(); // Ensure the change is reflected
      } catch (e) {
        // Handle errors (e.g., re-authentication required)
        throw Exception('Password update failed: $e');
      }
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
