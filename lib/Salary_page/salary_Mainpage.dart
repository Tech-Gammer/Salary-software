import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class salary_dashBoard extends StatefulWidget {
  const salary_dashBoard({super.key});

  @override
  State<salary_dashBoard> createState() => _salary_dashBoardState();
}

class _salary_dashBoardState extends State<salary_dashBoard> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = (screenWidth ~/ 200); // Each card should have a minimum width of 150

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("Salary DASHBOARD",style: GoogleFonts.lora(),),
        titleTextStyle: const TextStyle(
          fontSize: 25, // Responsive font size for title
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: columns,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DashboardCard(
                    title: "Arabian Salary",
                    icon: Icons.one_k,
                    onTap: () {
                      Navigator.pushNamed(context, '/arabian_salary');

                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
class DashboardCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DashboardCard({required this.title, required this.icon,required this.onTap});

  @override
  Widget build(BuildContext context) {



    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFFe6b67e)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}