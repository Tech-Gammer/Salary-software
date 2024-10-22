import 'package:flutter/material.dart';

class DepartmentProvider with ChangeNotifier {
  String _selectedDepartment = 'All'; // Default department

  String get selectedDepartment => _selectedDepartment;

  void setDepartment(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }
}
