import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary_soft/Auth/loginPage.dart';
import 'package:salary_soft/providers/adminprovider.dart';
import 'package:salary_soft/providers/authprovider.dart';
import 'package:salary_soft/providers/employee_providers.dart';
import 'package:salary_soft/providers/position_provider.dart';
import 'package:salary_soft/providers/shwoing_depart_provider.dart';
import 'Departments_page/total_Departments.dart';
import 'Empoyee_page/employee_Mainpage.dart';
import 'Empoyee_page/resticated_Employees.dart';
import 'Salary_page/salary_Mainpage.dart';
import 'Salary_page/salarypages/Arabian.dart';
import 'firebase_options.dart';
import 'firstPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // runApp(const MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DepartmentsProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()), // Add EmployeeProvider here
        ChangeNotifierProvider(create: (_) => AdminProvider()), // Add EmployeeProvider here
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => PositionsProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginPage(),
        '/frontPage': (context) => const dashBoard(),
        '/employeeDashboard': (context) => const employee_dashBoard(),
        '/totaldepartments': (context) => const totalDepartments(),
        '/resticated_employees': (context) => const resticatedEmployee(),
        '/salaryDashboard': (context) =>  const salary_dashBoard(),
        '/arabian_salary': (context) =>   arabianSalarysheet(),

      },
      title: 'Salary Software',

      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
