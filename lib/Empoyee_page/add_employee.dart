import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Models/employeemodel.dart';
import '../components.dart';
import '../providers/employee_providers.dart';
import 'employee_Mainpage.dart';

class addEmploy extends StatefulWidget {
  // const addEmploy({super.key});
  final Employee? employee; // Accept employee data, can be null for adding

  const addEmploy({Key? key, this.employee}) : super(key: key);
  @override
  State<addEmploy> createState() => _addEmployState();
}

class _addEmployState extends State<addEmploy> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _e_nameController = TextEditingController();
  TextEditingController _f_nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _idcardController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  // TextEditingController _positionController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();
  TextEditingController _residenceController = TextEditingController();

  User? currentUser;
  String? adminId;
  String? adminNumber;
  String? role;
  bool issaving= false;
  List<String> Departments = [];
  String? department;
  List<Map<String, String>> Positions = []; // Modify to hold maps
  String? position;  // Make sure it's nullable


void saveEmployee() async{
  if (formKey.currentState!.validate()) {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;
    String? positionName;
    if (position != null && Positions.isNotEmpty) {
      // Find the position_name based on the selected position_id
      final selectedPosition = Positions.firstWhere(
            (positionData) => positionData['position_id'] == position,
        orElse: () => {'position_name': 'Unknown'},  // Fallback to 'Unknown' if not found
      );
      positionName = selectedPosition['position_name'];
    }
    Employee employee = Employee(
      id: '',
      adminId: user?.uid ?? '',
      name: _e_nameController.text,
      fatherName: _f_nameController.text,
      age: _ageController.text,
      idCard: _idcardController.text,
      reference: _referenceController.text,
      joiningDate: _dateController.text,
      salary: _salaryController.text,
      residence: _residenceController.text,
      department: department ?? '',
      position:  positionName  ?? '',
      employeeStatus: "Active"
    );

    // Save the employee using the Provider
    Provider.of<EmployeeProvider>(context, listen: false).saveEmployee(employee);

    // Clear the text fields after saving
    _e_nameController.clear();
    _f_nameController.clear();
    _ageController.clear();
    _idcardController.clear();
    _referenceController.clear();
    _dateController.clear();
    _salaryController.clear();
    _residenceController.clear();
    // Reset department and position
    setState(() {
      department = '';
      position = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Employee saved successfully")),
    );
  }
}


  @override
  void initState() {
    super.initState();
    // Fetch positions and set the selected position based on employee data
    fetchPositions().then((_) {
      // Once positions are fetched, find the matching position_id for the employee's position_name
      if (widget.employee != null && widget.employee!.position.isNotEmpty) {
        final matchingPosition = Positions.firstWhere(
                (positionData) => positionData['position_name'] == widget.employee!.position,
            orElse: () => {'position_id': ''}  // Default to empty if not found
        );
        setState(() {
          position = matchingPosition['position_id'];  // Set the position_id for dropdown
        });
      }
    });    // Delay fetchEmployees until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees();
    });

    fetchDepartments();

    _e_nameController = TextEditingController(text: widget.employee?.name);
    _f_nameController = TextEditingController(text: widget.employee?.fatherName);
    _ageController = TextEditingController(text: widget.employee?.age.toString());
    _idcardController = TextEditingController(text: widget.employee?.idCard);
    _referenceController = TextEditingController(text: widget.employee?.reference);
    // _positionController = TextEditingController(text: widget.employee?.position);
    _dateController = TextEditingController(text: widget.employee?.joiningDate);
    _salaryController = TextEditingController(text: widget.employee?.salary.toString());
    _residenceController = TextEditingController(text: widget.employee?.residence);
    department = widget.employee?.department ?? '';  // Initialize with empty string if null
    position = widget.employee?.position ?? '';

}


  @override
  void dispose() {
    // Dispose of controllers
    _e_nameController.dispose();
    _f_nameController.dispose();
    _ageController.dispose();
    _idcardController.dispose();
    _referenceController.dispose();
    // _positionController.dispose();
    _dateController.dispose();
    _salaryController.dispose();
    _residenceController.dispose();
    super.dispose();
  }


  Future<void> fetchAdminData(String id) async {  // Changed parameter name to `id`
    final DatabaseReference adminRef = FirebaseDatabase.instance.ref('admin/$id');
    try {
      DataSnapshot snapshot = await adminRef.get();

      if (snapshot.exists) {
        final adminData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          adminId = id;  // Set the state variable correctly
          adminNumber = adminData['adminNumber'];
          role = adminData['role'];
        });
      } else {
        print('No data available for this user ID.');
      }
    } catch (error) {
      print('Error fetching admin data: $error');
    }
  }

  Future<void> fetchDepartments() async {
    try {
      final departmentRef = FirebaseDatabase.instance.ref("Departments");
      final snapshot = await departmentRef.once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        List<String> fetchDepartments = data.values.map((value) => value['depart_name'].toString()).toList();
        setState(() {
          Departments = fetchDepartments;
        });
      } else {
        setState(() {
          Departments = [];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPositions() async {
    print("$Positions");
    final DatabaseReference _database = FirebaseDatabase.instance.ref();

    // Listen for any changes in the "Employee_position" node
    _database.child("Employee_position").onValue.listen((event) {
      final positionsData = event.snapshot;
      List<Map<String, String>> loadedPositions = [];

      // Loop through the children of positionsData
      for (var position in positionsData.children) {
        loadedPositions.add({
          'position_name': position.child('position_name').value.toString(),
          'position_id': position.key.toString(),  // Store the key as position_id
        });
      }

      // Update state with the loaded positions
      setState(() {
        Positions = loadedPositions;  // Assign the loaded positions instead of an empty list
      });

      print("Positions fetched: $Positions");  // Print fetched positions for debugging
    });
  }

  String? _validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your CNIC';
    }
    String pattern = r'^\d{5}-\d{7}-\d{1}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid CNIC (XXXXX-XXXXXXX-X)';
    }
    return null;
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const employee_dashBoard()));
        }, icon: const Icon(Icons.arrow_back)),
        title: Text("ADD EMPLOYEES",style: GoogleFonts.lora(),),
        titleTextStyle: const TextStyle(
          fontSize: 25, // Responsive font size for title
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("images/background.jpg"), // Corrected path
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1), // Adjust opacity here
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Change if needed
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 70),
                        width: 800,
                        height: 600,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 5,color: Colors.blueAccent)
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Employee Form",style: GoogleFonts.lora(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent
                                  ),)
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _e_nameController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Employee Name",
                                        label: Text("Employee Name"),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                      ),
                                      validator: (value) => _validateNotEmpty(value, 'Employee Name'),
                                      textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _f_nameController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Employee F-Name",
                                        label: Text("Employee Father Name"),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                      ),
                                      validator: (value) => _validateNotEmpty(value, 'Employee Father Name'),
                                      textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _ageController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Employee Age",
                                        label: Text("Employee Age"),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                      ),
                                      validator: (value) => _validateNotEmpty(value, 'Employee Age'),
                                      textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _idcardController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Employee ID-Card Number",
                                        label: Text("Employee ID-Card Number"),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        CnicFormatter(),
                                      ],
                                      validator: _validateCNIC,

                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _referenceController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Employee Reference",
                                        label: Text("Reference"),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                      ),
                                      validator: (value) => _validateNotEmpty(value, 'Employee Reference'),
                                      textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                                    ),
                                  ),
                                ),
                                // Expanded(
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(8.0),
                                //     child: TextFormField(
                                //       controller: _positionController,
                                //       decoration: const InputDecoration(
                                //         hintText: "Enter Employee Position",
                                //         label: Text("Employee Position"),
                                //         border: OutlineInputBorder(
                                //           borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                //           borderRadius: BorderRadius.all(Radius.circular(15)),
                                //         ),
                                //       ),
                                //       validator: (value) => _validateNotEmpty(value, 'Employee Position'),
                                //       textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                                //     ),
                                //   ),
                                // ),

                                Expanded(
                                  child: Positions.isNotEmpty
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                        filled: true,
                                        labelText: "Position",
                                        labelStyle: TextStyle(fontSize: 15),
                                      ),
                                      value: position != '' ? position : null,
                                      items: Positions.map((positionData) {
                                        return DropdownMenuItem<String>(
                                          value: positionData['position_id'],  // Make sure this matches with `position`
                                          child: Text(positionData['position_name']!),  // Display the name
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          position = newValue;  // Update the selected position
                                        });
                                      },
                                      validator: (value) => value == null || value.isEmpty ? 'Select a position' : null,
                                    )


                                  )
                                      : const Center(child: CircularProgressIndicator()), // Show loader when Positions are empty
                                ),

                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 800,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: _dateController, // Use the date controller
                                        readOnly: true, // Make it read-only
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(onPressed: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(), // Current date
                                              firstDate: DateTime(2000), // First date selectable
                                              lastDate: DateTime.now(), // Last date selectable
                                            );
                                            if (pickedDate != null) {
                                              String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                              setState(() {
                                                _dateController.text = formattedDate; // Set the date to the text field
                                              });
                                            }
                                          }, icon: const Icon(Icons.date_range)),
                                          hintText: "Select Joining Date",
                                          labelText: "Employee Joining Date",
                                          border: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                          ),
                                        ),
                                        validator: (value) => _validateNotEmpty(value, 'Employee Joining Date'),

                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _salaryController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Employee Salary",
                                        label: Text("Employee Salary"),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                      ),
                                      validator: (value) => _validateNotEmpty(value, 'Employee Salary'),
                                      textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Departments.isNotEmpty
                                      ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DropdownButtonFormField<String>(
                                                                            decoration: const InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                        filled: true,
                                        labelText: "Department",
                                        labelStyle: TextStyle(fontSize: 15),),
                                          validator: (value) => _validateNotEmpty(value, 'Employee Department'),
                                          // value: department!.isEmpty ? null : department,
                                          value: department != '' ? department : null,  // If department is an empty string, set value to null
                                          items: Departments.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                       }).toList(),
                                        onChanged: (newValue) {
                                        setState(() {
                                          department = newValue!;
                                        });
                                       },
                                       ),
                                      ): const SingleChildScrollView()
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _residenceController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: "Enter Employee Residence",
                                    label: Text("Employee Residence"),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                  ),
                                  validator: (value) => _validateNotEmpty(value, "Employee Residence"),
                                  textCapitalization: TextCapitalization.words, // This capitalizes the first letter of each word
                                ),
                              ),
                            ),
                            Center(
                              child: Card(
                                child: InkWell(
                                  // onTap: issaving ? null : saveEmployee,
                                  onTap: issaving ? null : () {
                                    if (widget.employee != null) {
                                      updateEmployee(); // Call updateEmployee directly
                                    } else {
                                      saveEmployee();
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.2, // Set width to 60% of screen width
                                    height: 50.0,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Colors.blueAccent,
                                        Colors.greenAccent
                                      ]),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(
                                      child: issaving
                                          ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                          : Text(
                                        widget.employee != null ? 'Update Employee' : 'Save Employee',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),

    );
  }
  void updateEmployee() {
    if (formKey.currentState!.validate()) {
      String? positionName;
      if (position != null && Positions.isNotEmpty) {
        // Find the position_name based on the selected position_id
        final selectedPosition = Positions.firstWhere(
              (positionData) => positionData['position_id'] == position,
          orElse: () => {'position_name': 'Unknown'},  // Fallback to 'Unknown' if not found
        );
        positionName = selectedPosition['position_name'];
      }
      // Create an updated Employee object
      Employee updatedEmployee = Employee(
        id: widget.employee!.id,
        // Use the ID from the existing employee
        adminId: widget.employee!.adminId,
        name: _e_nameController.text,
        fatherName: _f_nameController.text,
        age: _ageController.text,
        idCard: _idcardController.text,
        reference: _referenceController.text,
        // position: _positionController.text,
        joiningDate: _dateController.text,
        salary: _salaryController.text,
        residence: _residenceController.text,
        department: department ?? '',
        position:  positionName ?? '',
        employeeStatus: "Active",
      );

      // Update the employee using the Provider
      Provider.of<EmployeeProvider>(context, listen: false).updateEmployee(
          updatedEmployee);

      // Optionally clear fields or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employee updated successfully")),
      );
    }
  }
}
