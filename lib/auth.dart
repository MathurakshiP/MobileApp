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
    return currentUser?.uid;
  }

  // Sign in user with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print("User signed in successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error signing in: $e");
      }
      throw Exception("Sign-in failed: $e");
    }
  }

  // Create new user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name in Firebase Authentication
      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();

      // Save additional user data to Firestore
      await _saveUserData(userCredential.user!, name);

      if (kDebugMode) {
        print("User created and data saved successfully.");
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user: $e");
      }
      throw Exception("User creation failed: $e");
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Initialize subcollections
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
        print("User data saved and subcollections initialized.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving user data: $e");
      }
      throw Exception("Failed to save user data to Firestore: $e");
    }
  }

  // Save recently viewed recipe to the user's subcollection
  Future<void> saveRecentlyViewedRecipe(String recipeId, String title, String image) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('recently_viewed')
          .doc(recipeId)
          .set({
        'recipeId': recipeId,
        'title': title,
        'image': image,
        'viewedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print("Recipe saved to 'recently_viewed' successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving recently viewed recipe: $e");
      }
      throw Exception("Failed to save recipe: $e");
    }
  }

  // Fetch the shopping list after user login
  Future<List<String>> getShoppingList() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      final shoppingListSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .get();

      final shoppingList = shoppingListSnapshot.docs
          .map((doc) => List<String>.from(doc['ingredients']))
          .expand((i) => i)
          .toList();

      if (kDebugMode) {
        print("Fetched shopping list: $shoppingList");
      }

      return shoppingList;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching shopping list: $e");
      }
      throw Exception("Failed to fetch shopping list: $e");
    }
  }

  // Update display name in Firebase Authentication and Firestore
  Future<void> updateDisplayName(String name) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      await user.updateDisplayName(name);
      await user.reload();
      await _updateUserDataInFirestore(user, name);

      if (kDebugMode) {
        print("Display name updated successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating display name: $e");
      }
      throw Exception("Failed to update display name: $e");
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserDataInFirestore(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
      });

      if (kDebugMode) {
        print("User data updated in Firestore.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user data in Firestore: $e");
      }
      throw Exception("Failed to update Firestore user data: $e");
    }
  }

  // Update password in Firebase Authentication
  Future<void> updatePassword(String newPassword) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      await user.updatePassword(newPassword);
      await user.reload();
      if (kDebugMode) {
        print("Password updated successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating password: $e");
      }
      throw Exception("Failed to update password: $e");
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (kDebugMode) {
        print("User signed out successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
      throw Exception("Failed to sign out: $e");
    }
  }
}
