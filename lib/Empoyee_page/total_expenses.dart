import 'dart:typed_data';
import 'dart:html' as html; // Import for web-based download functionality
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../Models/expensemodel.dart';
import '../providers/employee_providers.dart';

class ExpensesListPage extends StatefulWidget {
  const ExpensesListPage({Key? key}) : super(key: key);

  @override
  State<ExpensesListPage> createState() => _ExpensesListPageState();
}

class _ExpensesListPageState extends State<ExpensesListPage> {
  DateTimeRange? _selectedDateRange;
  List<Expense> _filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    final expenseProvider = Provider.of<EmployeeProvider>(context, listen: false);
    await expenseProvider.fetchAllExpenses();
    setState(() {
      _filteredExpenses = expenseProvider.expenses;
    });
  }

  void _filterExpensesByDateRange() {
    if (_selectedDateRange != null) {
      setState(() {
        _filteredExpenses = Provider.of<EmployeeProvider>(context, listen: false)
            .expenses
            .where((expense) {
          final expenseDate = DateTime.parse(expense.date);
          return expenseDate.isAfter(_selectedDateRange!.start) &&
              expenseDate.isBefore(_selectedDateRange!.end);
        }).toList();
      });
    }
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _filterExpensesByDateRange();
      });
    }
  }

  Future<void> _printPage() async {
    if (kIsWeb) {
      // For web: create and download the PDF file.
      final pdfData = await _generatePdf(PdfPageFormat.a4);
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "expenses_report.pdf")
        ..click();

      html.Url.revokeObjectUrl(url); // Clean up the object URL.
    } else {
      // For mobile or desktop platforms that support native printing
      await Printing.layoutPdf(onLayout: (format) => _generatePdf(format));
    }
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // Load the Jameel Noori Nastaleeq font from assets
    final jameelNooriFontData = await rootBundle.load("assets/fonts/JameelNooriNastaleeq.ttf");
    final jameelNooriFont = pw.Font.ttf(jameelNooriFontData);

    // Default font for English text
    final defaultFont = pw.Font.ttf(await rootBundle.load("assets/fonts/Lora-Italic-VariableFont_wght.ttf"));

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.Text("Expenses Report", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ["Type", "Employee ID", "Amount", "Description", "Date"],
                data: _filteredExpenses.map((e) {
                  final isUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(e.description);

                  return [
                    e.type,
                    e.employeeId,
                    e.amount,
                    pw.Text(
                      e.description,
                      style: pw.TextStyle(
                        font: isUrdu ? jameelNooriFont : defaultFont,
                        fontSize: 14,
                      ),
                    ),
                    DateFormat.yMMMd().format(DateTime.parse(e.date)),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Expenses"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printPage,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _filteredExpenses.isEmpty
            ? const Center(child: Text('No expenses found for selected date range.'))
            : ListView.builder(
          itemCount: _filteredExpenses.length,
          itemBuilder: (context, index) {
            final expense = _filteredExpenses[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(expense.type),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Employee: ${expense.employeeId}'),
                    Text('Amount: \$${expense.amount}'),
                    Text(
                      'Description: ${expense.description}',
                      style: const TextStyle(
                        fontFamily: 'JameelNoori',
                        fontSize: 25,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Date: ${DateFormat.yMMMd().format(DateTime.parse(expense.date))}',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
