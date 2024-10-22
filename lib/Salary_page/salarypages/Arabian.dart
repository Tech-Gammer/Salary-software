import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class arabianSalarysheet extends StatefulWidget {
  @override
  _arabianSalarysheetState createState() => _arabianSalarysheetState();
}

class _arabianSalarysheetState extends State<arabianSalarysheet> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("employees");
  final String departmentName = "Arabian"; // Define the department you want to filter by

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سیلری شیٹ',
          style: TextStyle(
            fontFamily: 'JameelNoori',
            fontSize: 40,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: dbRef.orderByChild('department').equalTo(departmentName).get(), // Fetching employees by department
        builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.value != null) {
              // Safely cast the data to Map<dynamic, dynamic>
              Map<dynamic, dynamic> employees = snapshot.data!.value as Map<dynamic, dynamic>;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('فہرست',style: TextStyle(
                      fontFamily: 'JameelNoori',
                      fontSize: 25,
                      color: Colors.black,
                    ),),
                    Table(
                      border: TableBorder.all(),
                      children: [
                        TableRow(
                          children: [
                            tableCell('چھٹیاں'),
                            tableCell('بقایا'),
                            tableCell('اضافہ/کٹوتی'),
                            tableCell('تنخواہ'),
                            tableCell('نام'),
                            tableCell('Joining Date'),
                            // tableCell('Increment Date'),
                            tableCell('نمبر شمار'),
                          ],
                        ),
                        ...employees.entries.map((entry) {
                          var emp = entry.value;
                          return TableRow(
                            children: [
                              tableCell(emp['deductions']?.toString() ?? '-'),  // Handle null
                              tableCell(emp['punishment']?.toString() ?? '0'),  // Handle null
                              tableCell(emp['extra_allowance']?.toString() ?? '-'),  // Handle null
                              tableCell(emp['salary']?.toString() ?? '0'),  // Handle null
                              tableCell(emp['name']?.toString() ?? 'نامعلوم'),  // Handle null
                              tableCell(emp['joiningDate']?.toString() ?? 'نامعلوم'),  // Handle null
                              // tableCell(emp['increment_date']?.toString() ?? 'نامعلوم'),  // Handle null
                              tableCell(entry.key.toString()),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data found.'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'JameelNoori',
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}
