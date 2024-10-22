class AdminModel {
  final String adminId;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String adminNumber;

  AdminModel(this.adminId, this.name, this.email, this.phone, this.password, this.role, this.adminNumber);

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'adminNumber': adminNumber
    };
  }
}
