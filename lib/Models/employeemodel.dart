class Employee {
  final String id; // Required
  final String adminId; // Required
  final String name;
  final String fatherName;
  final String age;
  final String idCard;
  final String reference;
  final String position;
  final String joiningDate;
  final String salary;
  final String residence;
  final String department;
  final String employeeStatus;
  final String? resticationDate;  // New field for restication date


  Employee({
    required this.id, // Make sure to add this
    required this.adminId, // Make sure to add this
    required this.name,
    required this.fatherName,
    required this.age,
    required this.idCard,
    required this.reference,
    required this.position,
    required this.joiningDate,
    required this.salary,
    required this.residence,
    required this.department,
    required this.employeeStatus,
    this.resticationDate,  // New field initialization

  });
}
