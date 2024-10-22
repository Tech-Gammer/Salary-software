import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salary_soft/providers/adminprovider.dart';
import 'Auth/loginPage.dart';
import 'Departments_page/total_Departments.dart';
import 'Empoyee_page/employee_Mainpage.dart';
import 'drawerfile.dart';


class dashBoard extends StatefulWidget {
  const dashBoard({super.key});

  @override
  State<dashBoard> createState() => _dashBoardState();
}

class _dashBoardState extends State<dashBoard>  with SingleTickerProviderStateMixin  {
  User? currentUser;
  String? adminId;
  String? adminNumber;
  String? role;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _contentSlideAnimation; // For the content slide
  bool isDrawerOpen = false;
  User? user; // Store the user information



  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Fetch admin data using provider
      Provider.of<AdminProvider>(context, listen: false).fetchAdminData(currentUser!.uid);
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _contentSlideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.18, 0.0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

  }





  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void toggleDrawer() {
    if (isDrawerOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }


  Widget _buildGridView(double screenWidth) {
    int crossAxisCount;

    // Determine the number of columns based on screen width using MediaQuery
    if (screenWidth < 600) {
      crossAxisCount = 2; // Mobile screens
    } else if (screenWidth < 1200) {
      crossAxisCount = 3; // Tablet screens
    } else {
      crossAxisCount = 5; // Large screens (like laptops and desktops)
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20.0,
      mainAxisSpacing: 20.0,
      padding: const EdgeInsets.all(16.0), // Add padding if necessary
      children: [
        DashboardItem(
          icon: Icons.work_outline,
          label: 'Employee Dashboard',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/employeeDashboard');
          },
        ),
        DashboardItem(
          icon: Icons.work_outline,
          label: 'Total Departments',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/totaldepartments');
          },
        ),
        // Add other DashboardItems as needed
        DashboardItem(
          icon: Icons.people_alt_outlined,
          label: 'Salary Sheet',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/salaryDashboard');
            // Navigator.push(context, MaterialPageRoute(builder: (context)=>const ManagersListPage()));
          },
        ),
        DashboardItem(
          icon: Icons.rule,
          label: 'Terminations',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/totalresticated');
          },
        ),
        DashboardItem(
          icon: Icons.rule,
          label: 'Goal Assignments',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/goalassignments');
          },
        ),DashboardItem(
          icon: Icons.rule,
          label: 'Total Goals',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/totalgoalslist');
          },
        ),

        // Add more items as needed
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Get screen size dynamically
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  double horizontalPadding = screenWidth * 0.03;
  double titleFontSize = screenWidth < 400 ? 18 : 24;

  double buttonSize = (screenWidth < 400)
      ? screenWidth * 0.2
      : (screenWidth < 600)
      ? screenWidth * 0.4
      : (screenWidth < 800)
      ? screenWidth * 0.25
      : screenWidth * 0.15;

  double buttonFontSize = (screenWidth < 400)
      ? 15
      : (screenWidth < 600)
      ? 17
      : 20;


    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
      automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: toggleDrawer,
          ),
      title: Text("Tech Gammer Production",style: GoogleFonts.lora(),),
      titleTextStyle: TextStyle(
        fontSize: titleFontSize, // Responsive font size for title
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
    ),
      body: Stack(
        children: [
          // Animated content that moves to the side when the drawer is open
          SlideTransition(
            position: _contentSlideAnimation,
            child: _buildGridView(screenSize.width), // Pass screen width for responsive grid
          ),
          // Drawer widget that slides in/out
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: screenSize.width * 0.18, // Adjust width of the drawer (80% of the screen)
              child:  const Drawerfrontside(), // Your custom drawer widget
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onButtonPressed;

  const DashboardItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onButtonPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.teal,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
