import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salary_soft/providers/shwoing_depart_provider.dart';

class addDepart extends StatefulWidget {
  const addDepart({super.key});

  @override
  State<addDepart> createState() => _addDepartState();
}

class _addDepartState extends State<addDepart> {
  final dref = FirebaseDatabase.instance.ref().child("Departments");
  final _departcontroller = TextEditingController();

  bool isRegisteringIn = false;
  String name = "";
  bool isSaving = false;


  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();


    return Scaffold(

      appBar: AppBar(
        title: Text("ADD DEPARTMENT",style: GoogleFonts.lora(),),
        titleTextStyle: const TextStyle(
          fontSize: 25, // Responsive font size for title
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
            image: const AssetImage("images/background.jpg"), // Corrected path
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1), // Adjust opacity here
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            Form(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Change if needed
                  children: [
                    Center(
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
                                controller: _departcontroller,
                                decoration: const InputDecoration(
                                  hintText: "Enter Department Name",
                                  label: Text("Department Name"),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                              ),
                            ),
                            const SizedBox(height: 30),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  if (_departcontroller.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please enter a department name")),
                                    );
                                  } else {
                                    setState(() {
                                      isSaving = true;
                                    });

                                    // Save department using the provider
                                    String result = await Provider.of<DepartmentsProvider>(context, listen: false)
                                        .saveDepartment(_departcontroller.text.trim());

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result)),  // Show the appropriate message based on the result
                                    );

                                    // Clear input and navigate back only if department was saved successfully
                                    if (result == "Department saved successfully") {
                                      setState(() {
                                        _departcontroller.clear();
                                      });
                                      Navigator.pop(context); // Close the page after saving successfully
                                    }
                                  }
                                },

                                child: Container(
                                  width: 200, // Ensure a proper size for layout
                                  height: 50.0, // Ensure a proper size for layout
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isSaving ? "Saving..." : "Save Category",
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            )
          ],
        ),
      ),
    );
  }
}
