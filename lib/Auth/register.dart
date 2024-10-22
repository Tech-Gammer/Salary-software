import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Models/datamodel.dart';
import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authentication = FirebaseAuth.instance;
  final nc = TextEditingController();
  final ec = TextEditingController();
  final phonec = TextEditingController();
  final pass = TextEditingController();
  final DatabaseReference dref = FirebaseDatabase.instance.ref();
  bool isRegistering = false; // Track the registration state

  // Function to register the user
  void RegisterUser() async {
    setState(() {
      isRegistering = true; // Set to true to block button
    });
    try {
      // Register the user with email and password
      UserCredential userCredential = await authentication.createUserWithEmailAndPassword(
        email: ec.text.trim(),
        password: pass.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Determine the next admin number by getting the last one assigned
      final DatabaseReference adminRef = dref.child('admin');
      DataSnapshot adminSnapshot = await adminRef.get();

      int adminNumber = 0; // Default to 1 if no admins exist
      if (adminSnapshot.exists) {
        // Get the highest current admin number to increment from
        for (var child in adminSnapshot.children) {
          int currentAdminNumber = int.parse(child.child('adminNumber').value.toString());
          if (currentAdminNumber >= adminNumber) {
            adminNumber = currentAdminNumber + 1; // Increment the highest number
          }
        }
      }

      // Create the Admin model
      AdminModel adminModel = AdminModel(
        uid,
        nc.text.trim(),
        ec.text.trim(),
        phonec.text.trim(),
        pass.text.trim(),
        '0', // '0' for admin role
        adminNumber.toString(), // Admin number
      );

      // Save the admin data to the admin node
      await adminRef.child(uid).set(adminModel.toMap());

      // Send verification email
      User? user = authentication.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent. Please check your email.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found for sending verification email.")),
        );
      }

      // Show success message and navigate to LoginPage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin registered successfully")),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));

    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }finally {
      setState(() {
        isRegistering = false; // Reset the button state
      });
    }
  }

  String? validatePhoneNumber(String? value) {
    // Define a regex pattern for valid phone numbers
    final RegExp phonePattern = RegExp(r'^(03[0-9]{9}|(\+92)[0-9]{10})$');

    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!phonePattern.hasMatch(value)) {
      return 'Please enter a valid phone number (03XXXXXXXXX or +92XXXXXXXXXX)';
    }
    return null; // Return null if validation passes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset("images/logo.png"),
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: nc,
                        textCapitalization: TextCapitalization.words, // Auto capitalize words
                        decoration: const InputDecoration(
                          hintText: "Enter Your Name",
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),

                          ),

                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: ec,

                        decoration: const InputDecoration(
                          hintText: "Enter Your Email Address",
                          labelText: "Email",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: phonec,
                        decoration: const InputDecoration(
                          hintText: "Enter Your Phone No",
                          labelText: "Phone No",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        validator: validatePhoneNumber, // Use the validation function
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: pass,
                        decoration: const InputDecoration(
                          hintText: "Enter Your Password",
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: InkWell(
                        onTap: isRegistering ? null : RegisterUser, // Block button if registering
                        child: Container(
                          width: 200.0,
                          height: 50.0,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.blueAccent,
                              Colors.greenAccent
                            ]),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: Text(
                              isRegistering ? "Registering..." : "Register",
                              style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text("If you are already registered, please click on"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
