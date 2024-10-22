import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary_soft/providers/adminprovider.dart';

class Drawerfrontside extends StatelessWidget {
  const Drawerfrontside({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the AdminProvider to fetch admin data
    final adminProvider = Provider.of<AdminProvider>(context);

    // Fetch the AdminModel from AdminProvider
    final adminModel = adminProvider.admin;

    // Handle loading or null case
    if (adminModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    double screenWidth = MediaQuery.of(context).size.width;

    double getFontSize() {
      if (screenWidth < 400) {
        return 10; // Small screens (phones)
      } else if (screenWidth < 600) {
        return 12; // Small to medium screens (large phones/small tablets)
      } else if (screenWidth < 900) {
        return 14; // Medium screens (tablets)
      } else if (screenWidth < 1200) {
        return 16; // Large screens (small laptops)
      } else {
        return 18; // Extra large screens (desktops)
      }
    }

    double getDrawerSize() {
      if (screenWidth < 400) {
        return screenWidth * 0.75; // For small screens, drawer is 75% of screen width
      } else if (screenWidth < 600) {
        return screenWidth * 0.5; // For medium screens, drawer is 50%
      } else {
        return screenWidth * 0.35; // For larger screens, drawer is 35%
      }
    }

    double fontSize = getFontSize();
    double drawerSize = getDrawerSize();

    // Display admin role based on role value
    String getRoleText(String role) {
      return role == "0" ? "Super Admin" : "Admin";
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Drawer(
        width: drawerSize,
        backgroundColor: const Color(0xFFDEE5D4),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role: ${getRoleText(adminModel.role)}',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: fontSize,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Name: ${adminModel.name}',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: fontSize * 0.9,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
