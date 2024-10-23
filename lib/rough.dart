// @override
// Widget build(BuildContext context) {
//
//   double screenWidth = MediaQuery.of(context).size.width;
//   double screenHeight = MediaQuery.of(context).size.height;
//
//   double horizontalPadding = screenWidth * 0.03;
//   double titleFontSize = screenWidth < 400 ? 18 : 24;
//
//   double buttonSize = (screenWidth < 400)
//       ? screenWidth * 0.2
//       : (screenWidth < 600)
//       ? screenWidth * 0.4
//       : (screenWidth < 800)
//       ? screenWidth * 0.25
//       : screenWidth * 0.15;
//
//   double buttonFontSize = (screenWidth < 400)
//       ? 15
//       : (screenWidth < 600)
//       ? 17
//       : 20;
//
//   return Scaffold(
//     appBar: AppBar(
//       automaticallyImplyLeading: false,
//       title: Text("Tech Gammer Production",style: GoogleFonts.lora(),),
//       titleTextStyle: TextStyle(
//         fontSize: titleFontSize, // Responsive font size for title
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//       centerTitle: true,
//       backgroundColor: Colors.lightBlueAccent,
//     ),
//     body: Row(
//       mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
//       children: [
//         // Card(
//         //   child: Directionality(
//         //     textDirection: TextDirection.rtl, // Change to rtl for Urdu
//         //     child: Text(
//         //       "یہ ایک مثال ہے",
//         //       style: TextStyle(
//         //         fontFamily: 'JameelNoori',
//         //         fontSize: 24,
//         //         color: Colors.black,
//         //       ),
//         //     ),
//         //   ),
//         // ),
//         Text("$role, $adminId, $adminNumber"),
//         Padding(
//           padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03, horizontal: horizontalPadding),
//           child: Card(
//             elevation: 10,
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(width: 2),
//                 borderRadius: const BorderRadius.all(Radius.circular(10))
//               ),
//               width: buttonSize,
//               child: TextButton(onPressed: (){
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>const totalDepartments()));
//               }, child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text("Departments",style: TextStyle(fontSize: buttonFontSize)),
//               )),
//             ),
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03, horizontal: horizontalPadding),
//           child: Card(
//             elevation: 10,
//             child: Container(
//               decoration: BoxDecoration(
//                   border: Border.all(width: 2),
//                   borderRadius: const BorderRadius.all(Radius.circular(10))
//               ),
//               width: buttonSize,
//               child: TextButton(onPressed: (){
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>const employee_dashBoard()));
//               }, child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text("Employees",style: TextStyle(fontSize: buttonFontSize),),
//               )),
//             ),
//           ),
//         ),
//       ],
//     ),
//     floatingActionButton: FloatingActionButton(
//       onPressed: () {
//         logout();
//       },
//       child: const Icon(Icons.logout, color: Colors.white),
//       backgroundColor: Colors.blueAccent,
//     ),
//
//   );
// }
//         Card(
//           child: Directionality(
//             textDirection: TextDirection.rtl, // Change to rtl for Urdu
//             child: Text(
//               "یہ ایک مثال ہے",
//               style: TextStyle(
//                 fontFamily: 'JameelNoori',
//                 fontSize: 24,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),


// Future<void> fetchPositions() async {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   _database.child("Employee_position").onValue.listen((event) {
//     final positionsData = event.snapshot;
//     List<String> loadedPositions = [];
//
//     for (var position in positionsData.children) {
//       loadedPositions.add(position.child('position_name').value.toString());
//     }
//
//     _position = loadedPositions;
//     notifyListeners();
//   });
// }
