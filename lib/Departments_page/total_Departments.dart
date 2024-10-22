import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salary_soft/providers/shwoing_depart_provider.dart';

import '../firstPage.dart';
import 'add_dapartments.dart';



class totalDepartments extends StatelessWidget {
  const totalDepartments({super.key});

  @override
  Widget build(BuildContext context) {
    final departmentProvider = Provider.of<DepartmentsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            // Navigate to the dashboard and remove all previous routes
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const dashBoard()),
                  (Route<dynamic> route) => false, // This will remove all previous routes
            );
          },
          icon: const Icon(Icons.home),
        ),

        title: Text(
          "TOTAL DEPARTMENTS",
          style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,

      ),
      body: departmentProvider.departments.isEmpty
          ? Center(
        child: SingleChildScrollView()
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: departmentProvider.departments.length,
        itemBuilder: (context, index) {
          String department = departmentProvider.departments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(department, style: GoogleFonts.lora()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => showDeleteConfirmationDialog(context, department),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => addDepart()));
          Provider.of<DepartmentsProvider>(context, listen: false).fetchDepartments();
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String departmentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the department '$departmentName'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<DepartmentsProvider>(context, listen: false).deleteDepartment(departmentName);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }


}
