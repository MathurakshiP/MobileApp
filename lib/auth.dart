import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get the current user's ID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

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
    required String name,
  }) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update the user's display name in Firebase Authentication
    await userCredential.user!.updateDisplayName(name);
    await userCredential.user!.reload();

    // After user is created, save additional user data to Firestore
    await _saveUserData(userCredential.user!, name);

    return userCredential;
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User user, String name) async {
    if (kDebugMode) {
      print('email');
    }
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': name, // Save name
        'display': name,
      });

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('recently_viewed')
          .doc('initial_document')
          .set({
        'initialized': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print("User data saved and 'recently_viewed' subcollection created.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving user data: $e");
      }
      throw Exception("Error saving user data to Firestore");
    }
  }

  // Save recently viewed recipe to the user's subcollection
  Future<void> saveRecentlyViewedRecipe(String recipeId, String title, String image) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final userId = user.uid;

      final recentlyViewedRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recently_viewed');

      try {
        await recentlyViewedRef.doc(recipeId).set({
          'recipeId': recipeId,
          'title': title,
          'image': image,
          'viewedAt': FieldValue.serverTimestamp(),
        });
        if (kDebugMode) {
          print("Successfully saved recipe to 'recently_viewed' subcollection.");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error saving recently viewed recipe: $e");
        }
        throw Exception("Error saving recipe to Firestore");
      }
    } else {
      if (kDebugMode) {
        print("User is not authenticated.");
      }
      throw Exception("User is not authenticated");
    }
  }

  // Update display name in Firebase Authentication and Firestore
  Future<void> updateDisplayName(String name) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload(); // Ensure the change is reflected
      await _updateUserDataInFirestore(user, name);
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserDataInFirestore(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
      });
      if (kDebugMode) {
        print("User data updated successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data: $e");
      }
      throw Exception("Error updating user data in Firestore");
    }
  }

  // Update password in Firebase Authentication
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        await user.reload(); // Ensure the change is reflected
      } catch (e) {
        throw Exception('Password update failed: $e');
      }
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
