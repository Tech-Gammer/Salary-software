import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/position_provider.dart';

class EmployeeRole extends StatefulWidget {
  const EmployeeRole({super.key});

  @override
  State<EmployeeRole> createState() => _EmployeeRoleState();
}

class _EmployeeRoleState extends State<EmployeeRole> {
  final dref = FirebaseDatabase.instance.ref().child("Employee_position");
  final _rolecontroller = TextEditingController();

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ADD Role for Employee",
          style: GoogleFonts.lora(),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("images/background.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Form(
          key: formKey,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 130),
              width: 500,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _rolecontroller,
                      decoration: const InputDecoration(
                        hintText: "Enter Position Name",
                        label: Text("Position Name"),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a position name';
                        }
                        return null; // Valid input
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: InkWell(
                      onTap: () async {
                        print('enter');
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isSaving = true; // Set saving state
                          });

                          // Save position using the provider
                          String result = await Provider.of<PositionsProvider>(context, listen: false)
                              .savePosition(_rolecontroller.text.trim());

                          // Show feedback using SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );

                          // Clear input and navigate back only if position was saved successfully
                          if (result == "Position saved successfully") {
                            _rolecontroller.clear(); // Clear the input field
                            Navigator.pop(context); // Close the page after saving successfully
                          }

                          setState(() {
                            isSaving = false; // Reset saving state
                          });
                        }
                      },
                      child: Container(
                        width: 200,
                        height: 50.0,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Center(
                          child: Text(
                            isSaving ? "Saving..." : "Save Role",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
