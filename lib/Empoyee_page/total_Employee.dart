import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Models/employeemodel.dart';
import '../firstPage.dart';
import '../providers/employee_providers.dart';
import 'add_employee.dart';

class totalEmployee extends StatefulWidget {
  const totalEmployee({super.key});

  @override
  State<totalEmployee> createState() => _totalEmployeeState();
}

class _totalEmployeeState extends State<totalEmployee> {

  @override
  void initState() {
    super.initState();
    // Fetch employees after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees();
    });
  }


  @override
  Widget build(BuildContext context) {

    final employeeProvider = Provider.of<EmployeeProvider>(context);

    // Calculate the maximum width for each column
    double maxWidthForColumn(String columnName, List<Employee> employees) {
      double maxWidth = columnName.length.toDouble() * 10; // Base width
      for (var employee in employees) {
        switch (columnName) {
          case 'Name':
            maxWidth = max(maxWidth, employee.name.length.toDouble() * 10);
            break;
          case 'Father Name':
            maxWidth = max(maxWidth, employee.fatherName.length.toDouble() * 10);
            break;
          case 'Age':
            maxWidth = max(maxWidth, employee.age.toString().length.toDouble() * 10);
            break;
          case 'ID Card':
            maxWidth = max(maxWidth, employee.idCard.length.toDouble() * 10);
            break;
          case 'Reference':
            maxWidth = max(maxWidth, employee.reference.length.toDouble() * 10);
            break;
          case 'Position':
            maxWidth = max(maxWidth, employee.position.length.toDouble() * 10);
            break;
          case 'Joining Date':
            maxWidth = max(maxWidth, employee.joiningDate.length.toDouble() * 10);
            break;
          case 'Salary':
            maxWidth = max(maxWidth, employee.salary.toString().length.toDouble() * 10);
            break;
          case 'Residence':
            maxWidth = max(maxWidth, employee.residence.length.toDouble() * 5);
            break;
        }
      }
      return maxWidth + 20; // Add some padding
    }

    // Calculate widths for each column

    double nameColumnWidth = maxWidthForColumn('Name', employeeProvider.employees);
    double fatherNameColumnWidth = maxWidthForColumn('Father Name', employeeProvider.employees);
    double ageColumnWidth = maxWidthForColumn('Age', employeeProvider.employees);
    double idCardColumnWidth = maxWidthForColumn('ID Card', employeeProvider.employees);
    double referenceColumnWidth = maxWidthForColumn('Reference', employeeProvider.employees);
    double positionColumnWidth = maxWidthForColumn('Position', employeeProvider.employees);
    double joiningDateColumnWidth = maxWidthForColumn('Joining Date', employeeProvider.employees);
    double salaryColumnWidth = maxWidthForColumn('Salary', employeeProvider.employees);
    double residenceColumnWidth = maxWidthForColumn('Residence', employeeProvider.employees);
    double actionColumnWidth = 100; // Width for action buttons


    void showDeleteConfirmation(Employee employee) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Confirmation'),
            content: Text('Are you sure you want to delete ${employee.name}?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Provider.of<EmployeeProvider>(context, listen: false)
                      .deleteEmployee(employee.id);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('No'),
              ),
            ],
          );
        },
      );
    }

    void showResticateConfirmation(Employee employee) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Resticate Confirmation'),
            content: Text('Are you sure you want to resticate ${employee.name}?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Move the employee to resticated_employee node
                  Provider.of<EmployeeProvider>(context, listen: false)
                      .resticateEmployee(employee.id);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('No'),
              ),
            ],
          );
        },
      );
    }




    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const dashBoard()),
                  (Route<dynamic> route) => false, // This will remove all previous routes
            );
          },
          icon: const Icon(Icons.home),
        ),

        title: Text(
          "TOTAL Employees",
          style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,

      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("images/background.jpg"), // Your background image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1), // Adjust opacity as needed
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 70),
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight, // Use available space, but don't overflow
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(width: 5, color: Colors.blueAccent),
                  ),
                  child: employeeProvider.employees.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 12, // Add space between columns
                        border: const TableBorder.symmetric(
                          inside: BorderSide(color: Colors.black, width: 0.3), // Only vertical borders
                        ),
                        columns: [
                          const DataColumn(label: SizedBox(width: 50, child: Text('No', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))), // Counting column
                          DataColumn(label: SizedBox(width: nameColumnWidth, child: const Text('Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: fatherNameColumnWidth, child: const Text('Father Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: ageColumnWidth, child: const Text('Age', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: idCardColumnWidth, child: const Text('ID Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: referenceColumnWidth, child: const Text('Reference', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: referenceColumnWidth, child: const Text('Department', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: positionColumnWidth, child: const Text('Position', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: joiningDateColumnWidth, child: const Text('Joining Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: salaryColumnWidth, child: const Text('Salary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: residenceColumnWidth, child: const Text('Residence', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                          DataColumn(label: SizedBox(width: actionColumnWidth, child: const Text('Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                        ],
                        rows: employeeProvider.employees.asMap().entries.map((entry) {
                          int index = entry.key; // Get the index
                          Employee employee = entry.value; // Get the employee
                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())), // Display the index + 1 for 1-based counting
                              DataCell(Text(employee.name)),
                              DataCell(Text(employee.fatherName)),
                              DataCell(Text(employee.age.toString())),
                              DataCell(Text(employee.idCard)),
                              DataCell(Text(employee.reference)),
                              DataCell((Text(employee.department))),
                              DataCell(Text(employee.position)),
                              DataCell(Text(employee.joiningDate)),
                              DataCell(Text(employee.salary.toString())),
                              DataCell(
                                Text(
                                  employee.residence,
                                  maxLines: 3, // Show up to 3 lines
                                  overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                                  style: const TextStyle(height: 1.2),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        // Implement update functionality here
                                        // _showUpdateDialog(employee);
                                        Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => addEmploy(employee: employee), // Pass the employee data
                                              ),
                                         );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        // Implement delete functionality here
                                        showDeleteConfirmation(employee);
                                      },
                                    ),IconButton(
                                      icon: const Icon(Icons.remove, color: Colors.red),
                                      onPressed: () {
                                        // Implement delete functionality here
                                        showResticateConfirmation(employee); // Call resticate confirmation dialog
                                      },
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
