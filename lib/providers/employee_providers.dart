import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart';
import '../Models/employeemodel.dart';
import '../Models/expensemodel.dart';

class EmployeeProvider with ChangeNotifier {
  List<Employee> _employees = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  List<Employee> get employees => _employees;
  List<Employee> resticatedEmployees = []; // List for resticated employees


  Future<void> saveEmployee(Employee employee) async {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;

    // Create a new entry in the database under "employees"
    String id = _database.child("employees").push().key!;

    // Save employee data along with user ID
    await _database.child("employees").child(id).set({
      'adminId': user?.uid,
      'employeeId': id,
      'name': employee.name,
      'fatherName': employee.fatherName,
      'age': employee.age,
      'idCard': employee.idCard,
      'reference': employee.reference,
      'position': employee.position,
      'joiningDate': employee.joiningDate,
      'salary': employee.salary,
      'residence': employee.residence,
      'department':employee.department,
      'employeeStatus': 'Active'
    });

    _employees.add(employee);
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  Future<void> fetchEmployees() async {
    _database.child("employees").onValue.listen((event) {
      final employeesData = event.snapshot;
      List<Employee> loadedEmployees = [];
      for (var emp in employeesData.children) {
        // Fetch employee status
        String status = emp.child('employeeStatus').value.toString();

        // Filter to load only active employees
        if (status == 'Active') {
          final employee = Employee(
            id: emp.key!, // Use the key as the id
            adminId: emp.child('adminId').value.toString(),
            name: emp.child('name').value.toString(),
            fatherName: emp.child('fatherName').value.toString(),
            age: emp.child('age').value.toString(),
            idCard: emp.child('idCard').value.toString(),
            reference: emp.child('reference').value.toString(),
            position: emp.child('position').value.toString(),
            joiningDate: emp.child('joiningDate').value.toString(),
            salary: emp.child('salary').value.toString(),
            residence: emp.child('residence').value.toString(),
            department: emp.child('department').value.toString(),
            employeeStatus: status, // Fetch employee status
          );
          loadedEmployees.add(employee);
        }
      }
      _employees = loadedEmployees;
      notifyListeners();
    });
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      // Check employee status before deletion
      Employee employee = _employees.firstWhere((e) => e.id == employeeId);
      if (employee.employeeStatus == 'Active') {
        print("Attempting to delete employee with ID: $employeeId");
        await _database.child("employees").child(employeeId).remove();
        // Remove the employee from the local list
        _employees.removeWhere((employee) => employee.id == employeeId);
        notifyListeners(); // Notify listeners to rebuild the UI
      } else {
        print("Cannot delete employee with status: ${employee.employeeStatus}");
      }
    } catch (error) {
      print("Error deleting employee: $error");
    }
  }

  Future<void> resticateEmployee(String id) async {
    try {
      // Find the employee to resticate
      Employee employee = employees.firstWhere((employee) => employee.id == id);

      User? user = FirebaseAuth.instance.currentUser;

      String resticationDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

      // Create a map for the employee data
      Map<String, dynamic> employeeData = {
        'adminId': user?.uid,
        'employeeId': id,
        'name': employee.name,
        'fatherName': employee.fatherName,
        'age': employee.age,
        'idCard': employee.idCard,
        'reference': employee.reference,
        'position': employee.position,
        'joiningDate': employee.joiningDate,
        'salary': employee.salary,
        'residence': employee.residence,
        'department': employee.department,
        'resticationDate': resticationDate, // Add restication date
        'employeeStatus': 'Resticated' // Change employee status to Resticated
      };

      // Add to resticated employees node in Realtime Database
      await _database.child('resticated_employee').child(employee.id).set(employeeData);

      // Remove the employee from the active employees node
      await _database.child('employees').child(employee.id).remove();

      // Remove from the local list
      employees.remove(employee);

      // Notify listeners for UI updates
      notifyListeners();
    } catch (e) {
      print("Error moving employee to resticated: $e");
    }
  }

  Future<List<Employee>> fetchEmployeesByDepartment(String department) async {
    final DataSnapshot snapshot = await _database.child("employees").get();
    List<Employee> loadedEmployees = [];

    for (var emp in snapshot.children) {
      String status = emp.child('employeeStatus').value.toString();
      if (emp.child('department').value.toString() == department && status == 'Active') {
        final employee = Employee(
          id: emp.key!,
          adminId: emp.child('adminId').value.toString(),
          name: emp.child('name').value.toString(),
          fatherName: emp.child('fatherName').value.toString(),
          age: emp.child('age').value.toString(),
          idCard: emp.child('idCard').value.toString(),
          reference: emp.child('reference').value.toString(),
          position: emp.child('position').value.toString(),
          joiningDate: emp.child('joiningDate').value.toString(),
          salary: emp.child('salary').value.toString(),
          residence: emp.child('residence').value.toString(),
          department: emp.child('department').value.toString(),
          employeeStatus: status, // Fetch employee status
        );
        loadedEmployees.add(employee);
      }
    }

    return loadedEmployees;
  }

  Future<void> saveExpense(Expense expense) async {
    try {
      String id = _database.child("expenses").push().key!;

      await _database.child("expenses").child(id).set({
        'employeeId': expense.employeeId,
        'type': expense.type,
        'amount': expense.amount,
        'description': expense.description,
        'date': expense.date,
      });

      // Optionally notify listeners if you maintain a list of expenses
      // notifyListeners();
    } catch (error) {
      print("Error saving expense: $error");
      // Optionally, you could show a dialog or Snackbar for error feedback
    }
  }


  Future<void> updateEmployee(Employee employee) async {
    // Assuming you're using a Firebase Realtime Database
    final DatabaseReference employeeRef = FirebaseDatabase.instance.ref('employees/${employee.id}');
    try {
      await employeeRef.set({
        'adminId': employee.adminId,
        'name': employee.name,
        'fatherName': employee.fatherName,
        'age': employee.age,
        'idCard': employee.idCard,
        'reference': employee.reference,
        'position': employee.position,
        'joiningDate': employee.joiningDate,
        'salary': employee.salary,
        'residence': employee.residence,
        'department': employee.department,
        'employeeStatus': employee.employeeStatus,
      });
      // Notify listeners or handle any post-update actions
      notifyListeners();
    } catch (error) {
      // Handle errors
      print('Error updating employee: $error');
    }
  }

  Future<void> fetchresticatedEmployees() async {
    try {
      // Reference to the resticated_employee node in Firebase
      final DatabaseReference ref = FirebaseDatabase.instance.ref("resticated_employee");

      // Get data from the Firebase node
      final DataSnapshot snapshot = await ref.get();

      // Clear the current employee list
      _employees.clear();

      if (snapshot.exists) {
        // Iterate over the snapshot to extract employees with employeeStatus = "Resticated"
        Map<String, dynamic> employeesData = Map<String, dynamic>.from(snapshot.value as Map);
        employeesData.forEach((key, value) {
          var employeeData = Map<String, dynamic>.from(value);
          if (employeeData['employeeStatus'] == 'Resticated') {
            Employee employee = Employee(
              id: key,
              adminId: employeeData['adminId'] ?? '', // Assign adminId
              name: employeeData['name'] ?? '',
              fatherName: employeeData['fatherName'] ?? '',
              age: employeeData['age'] ?? '0',
              idCard: employeeData['idCard'] ?? '',
              reference: employeeData['reference'] ?? '',
              position: employeeData['position'] ?? '',
              joiningDate: employeeData['joiningDate'] ?? '',
              salary: employeeData['salary'] ?? '0',
              residence: employeeData['residence'] ?? '',
              department: employeeData['department'] ?? '',
              employeeStatus: employeeData['employeeStatus'] ?? '',
              resticationDate: employeeData['resticationDate'] ?? '',

            );
            _employees.add(employee);
          }
        });
      }
      notifyListeners(); // Notify listeners that the employee list has been updated
    } catch (e) {
      print('Error fetching resticated employees: $e');
    }
  }





}


