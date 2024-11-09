class Expense {
  final String expenseId;

  final String employeeId;
  final String type;
  final String amount;
  final String description;
  final String date;

  Expense({
    required this.expenseId,
    required this.employeeId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });
}
