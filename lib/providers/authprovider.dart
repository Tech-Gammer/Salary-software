import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggingIn = false;

  // Function to handle login
  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Set loading to true
      isLoggingIn = true;
      notifyListeners();

      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Get the user ID
      String uid = userCredential.user?.uid ?? '';

      // Reference to the admin node
      DatabaseReference adminRef = FirebaseDatabase.instance.ref("admin/$uid");

      // Check if the user is in the admin node
      DataSnapshot adminSnapshot = await adminRef.get();

      if (adminSnapshot.exists) {
        // User is in the admin node
        Map<dynamic, dynamic> adminData = adminSnapshot.value as Map<dynamic, dynamic>;
        String role = adminData['role'] ?? '';

        if (role == '0') {
          // Navigate to the admin dashboard
          Navigator.pushReplacementNamed(context, '/frontPage');
        } else {
          // Show error if not admin
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access denied: Not an admin.')),
          );
        }
      } else {
        // Show error if user not found in admin node
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access denied: Not an admin.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Show authentication error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      // Set loading to false
      isLoggingIn = false;
      notifyListeners();
    }
  }
}
