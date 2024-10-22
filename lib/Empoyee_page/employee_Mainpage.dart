import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salary_soft/Empoyee_page/add_employee.dart';
import 'package:salary_soft/Empoyee_page/total_Employee.dart';

import '../Models/employeemodel.dart';
import 'employee_expenses.dart';

class employee_dashBoard extends StatefulWidget {
  const employee_dashBoard({super.key});

  @override
  State<employee_dashBoard> createState() => _employee_dashBoardState();
}

class _employee_dashBoardState extends State<employee_dashBoard> {
  // List<String> Employees = [];
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Employee> _employees = [];
  List<Employee> get employees => _employees;
  int _resticatedEmployeeCount = 0; // Add this variable to track the count of Resticated employees

 @override
  void initState() {
    super.initState();
    fetchEmployees();
    fetchresticatedEmployees(); // Fetch Resticated employees

 }

  Future<void> fetchEmployees() async {
    _database.child("employees").onValue.listen((event) {
      final employeesData = event.snapshot;
      List<Employee> loadedEmployees = [];

      for (var emp in employeesData.children) {
        // Fetching the employee status
        String employeeStatus = emp.child('employeeStatus').value.toString();

        // Check if the employee status is "Active"
        if (employeeStatus == "Active") {
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
            employeeStatus: employeeStatus, // Add this line if your model has this field
          );
          loadedEmployees.add(employee);
        }
      }

      setState(() {
        _employees = loadedEmployees; // Update state with the filtered list
      });
    });
  }

// Fetch Resticated Employees Count
  Future<void> fetchresticatedEmployees() async {
    _database.child("resticated_employee").onValue.listen((event) {
      final employeesData = event.snapshot;
      int resticatedCount = 0;

      for (var emp in employeesData.children) {
        String employeeStatus = emp.child('employeeStatus').value.toString();
        if (employeeStatus == "Resticated") {
          resticatedCount++;
        }
      }

      setState(() {
        _resticatedEmployeeCount = resticatedCount; // Update the resticated count
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = (screenWidth ~/ 200); // Each card should have a minimum width of 150

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("EMPLOYEE DASHBOARD",style: GoogleFonts.lora(),),
        titleTextStyle: const TextStyle(
          fontSize: 25, // Responsive font size for title
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: columns,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DashboardCard(
                    title: "Employees List",
                    icon: Icons.list,
                    count: _employees.length.toString(),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const totalEmployee()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DashboardCard(
                    title: " Add New\nEmployees",
                    icon: Icons.add,
                    count: _employees.length.toString(),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const addEmploy()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DashboardCard(
                    title: "Add Employees\n     EXPENSES",
                    icon: Icons.add,
                    count: _employees.length.toString(),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeExpenses()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DashboardCard(
                    title: "Total\n     Restications",
                    icon: Icons.add,
                    count: _resticatedEmployeeCount.toString(), // Show resticated count here
                    onTap: () {
                      Navigator.pushNamed(context, '/resticated_employees');
                    },
                  ),
                ),

              ],
            ),
          ),
        ],
      ),

    );
  }
}
class DashboardCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final String count;
  final VoidCallback onTap;

  DashboardCard({required this.title, required this.icon, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {



    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFFe6b67e)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}