import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DepartmentsProvider with ChangeNotifier {
  List<String> _departments = [];
  final DatabaseReference dref = FirebaseDatabase.instance.ref().child("Departments");

  List<String> get departments => _departments;

  DepartmentsProvider() {
    fetchDepartments(); // Fetch the departments when the provider is initialized
  }

  Future<void> fetchDepartments() async {
    try {
      final departmentRef = FirebaseDatabase.instance.ref('Departments');
      final snapshot = await departmentRef.once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        List<String> fetchedDepartments = data.values.map((value) => value['depart_name'].toString()).toList();
        _departments = fetchedDepartments;
      } else {
        _departments = [];
      }
      notifyListeners(); // Notify listeners when the state is updated
    } catch (e) {
      print('Error fetching Departments: $e');
    }
  }


  Future<void> deleteDepartment(String departmentName) async {
    try {
      final departmentRef = FirebaseDatabase.instance.ref("Departments");
      final snapshot = await departmentRef.orderByChild("depart_name").equalTo(departmentName).once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        final key = data.keys.first;

        // Remove the department from Firebase
        await departmentRef.child(key).remove();

        // Remove from local list
        _departments.remove(departmentName);
        notifyListeners(); // Notify listeners when a department is deleted
      }
    } catch (e) {
      print('Error deleting department: $e');
    }
  }


  Future<bool> checkForDuplicate(String departName) async {
    final normalizedDepartName = departName.toLowerCase();  // Convert input to lowercase
    final snapshot = await dref.once();

    if (snapshot.snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      // Check if any department name in the database matches the input name (ignoring case)
      for (var value in data.values) {
        final dbDepartName = value['depart_name'].toString().toLowerCase();  // Convert database name to lowercase
        if (dbDepartName == normalizedDepartName) {
          return true;  // Duplicate found
        }
      }
    }
    return false;  // No duplicate found
  }


  Future<String> saveDepartment(String depart_name) async {
    bool isDuplicate = await checkForDuplicate(depart_name);

    // If it's a duplicate, return an appropriate message
    if (isDuplicate) {
      return "Department already exists"; // Return this message if it's a duplicate
    } else {
      // If it's not a duplicate, proceed to save the department
      String id = dref.push().key.toString();
      await dref.child(id).set({
        'depart_name': depart_name,  // Save the original case-sensitive name
        'depart_id': id,
      });
      await fetchDepartments(); // Update the local list after adding the new department
      return "Department saved successfully";
    }
  }
  }
