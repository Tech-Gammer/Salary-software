import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Models/employeemodel.dart';
import '../Models/expensemodel.dart';
import '../providers/employee_providers.dart';
import '../providers/shwoing_depart_provider.dart'; // Adjust this path

class EmployeeExpenses extends StatefulWidget {
  const EmployeeExpenses({Key? key}) : super(key: key);

  @override
  State<EmployeeExpenses> createState() => _EmployeeExpensesState();
}

class _EmployeeExpensesState extends State<EmployeeExpenses> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedExpenseType;
  String? _selectedDepartment;
  String? _selectedEmployee;
  String _amount = '';
  String _description = '';

  // List of expense types
  final List<String> _expenseTypes = [
    'Loan Payment',
    'Food Material on Credit',
    'Rent',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final departmentsProvider = Provider.of<DepartmentsProvider>(context);
    final expenseProvider = Provider.of<EmployeeProvider>(context); // Add this line
    // Get the filtered employees based on the selected department
    List<Employee> filteredEmployees = _selectedDepartment != null
        ? employeeProvider.employees
        .where((employee) => employee.department == _selectedDepartment)
        .toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text("EMPLOYEE EXPENSES", style: GoogleFonts.lora()),
        titleTextStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown for selecting expense type
              DropdownButtonFormField<String>(
                value: _selectedExpenseType,
                hint: const Text('Select Expense Type'),
                items: _expenseTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedExpenseType = newValue;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select an expense type' : null,
              ),

              // Dropdown for selecting department
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                hint: const Text('Select Department'),
                items: departmentsProvider.departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDepartment = newValue;
                    _selectedEmployee = null; // Reset employee selection
                  });

                  // Fetch employees for the selected department
                  if (newValue != null) {
                    Provider.of<EmployeeProvider>(context, listen: false)
                        .fetchEmployeesByDepartment(newValue)
                        .then((_) {
                      setState(() {
                        // Rebuild the widget to reflect the new list of employees
                      });
                    });
                  }
                },
                validator: (value) =>
                value == null ? 'Please select a department' : null,
              ),
              const SizedBox(height: 16.0),

              // Dropdown for selecting employee
              DropdownButtonFormField<String>(
                value: _selectedEmployee,
                hint: const Text('Select Employee'),
                items: filteredEmployees.map((Employee employee) {
                  return DropdownMenuItem<String>(
                    value: employee.id, // Use the employee ID for selection
                    child: Text(employee.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedEmployee = newValue;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select an employee' : null,
              ),
              const SizedBox(height: 16.0),

              // Text field for amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _amount = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Text field for description
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Create the Expense object
                    Expense expense = Expense(
                      employeeId: _selectedEmployee!,
                      type: _selectedExpenseType!,
                      amount: _amount,
                      description: _description,
                      date: DateTime.now().toIso8601String(), // Current date
                    );

                    // Call saveExpense method from the provider to save expense to Firebase
                    expenseProvider.saveExpense(expense).then((_) {
                      // Clear the form after submission
                      _formKey.currentState!.reset();
                      setState(() {
                        _selectedExpenseType = null;
                        _selectedDepartment = null; // Reset department selection
                        _selectedEmployee = null;
                        _amount = '';
                        _description = '';
                      });

                      // Show confirmation dialog or message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Expense added successfully!')),
                      );
                    }).catchError((error) {
                      // Handle error if saving fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add expense: $error')),
                      );
                    });
                  }
                },
                child: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
