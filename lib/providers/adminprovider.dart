import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Models/datamodel.dart';

class AdminProvider with ChangeNotifier {
  AdminModel? _admin;

  AdminModel? get admin => _admin;

  // Function to fetch admin role and name
  Future<void> fetchAdminData(String adminId) async {
    try {
      DatabaseReference adminRef = FirebaseDatabase.instance.ref('admin/$adminId');

      DataSnapshot snapshot = await adminRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        // Assuming your data structure in Firebase has name and role
        String name = data['name'] ?? 'Unknown';
        String role = data['role'] ?? 'Unknown';

        // Create an updated AdminModel
        _admin = AdminModel(
          adminId,
          name,
          data['email'] ?? 'Unknown',
          data['phone'] ?? 'Unknown',
          data['password'] ?? 'Unknown',
          role,
          data['adminNumber'] ?? 'Unknown',
        );

        // Notify listeners that admin data has been updated
        notifyListeners();
      } else {
        print('Admin not found in database');
      }
    } catch (error) {
      print('Failed to fetch admin data: $error');
    }
  }
}
