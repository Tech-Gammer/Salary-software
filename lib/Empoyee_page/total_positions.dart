import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../firstPage.dart';
import '../providers/position_provider.dart';
import 'employee_position.dart';

class TotalPositions extends StatelessWidget {
  const TotalPositions({super.key});

  @override
  Widget build(BuildContext context) {
    final positionsProvider = Provider.of<PositionsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const dashBoard()),
                  (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.home),
        ),
        title: Text(
          "TOTAL POSITIONS",
          style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: positionsProvider.positions.isEmpty
          ? Center(child: Text("No Positions Available", style: GoogleFonts.lora(fontSize: 20)))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: positionsProvider.positions.length,
        itemBuilder: (context, index) {
          String positionName = positionsProvider.positions[index]['position_name']!;
          String positionId = positionsProvider.positions[index]['position_id']!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(positionName, style: GoogleFonts.lora()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => showDeleteConfirmationDialog(context, positionName, positionId),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeRole())); // Change to your add position page
          Provider.of<PositionsProvider>(context, listen: false).fetchPositions();
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String positionName, String positionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the position '$positionName'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<PositionsProvider>(context, listen: false).deletePosition(positionId); // Pass the positionId for deletion
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }}
