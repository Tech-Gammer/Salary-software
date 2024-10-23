import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PositionsProvider with ChangeNotifier {
  // List<String> _position = [];
  List<Map<String, String>> _positions = [];  // Store positions as a list of maps

  final DatabaseReference dref = FirebaseDatabase.instance.ref("Employee_position");
  List<Map<String, String>> get positions => _positions;

  // List<String> get positions => _position;

  PositionsProvider() {
    fetchPositions(); // Fetch the position when the provider is initialized
  }



  Future<void> fetchPositions() async {
    final DatabaseReference _database = FirebaseDatabase.instance.ref();
    _database.child("Employee_position").onValue.listen((event) {
      final positionsData = event.snapshot;
      List<Map<String, String>> loadedPositions = [];

      for (var position in positionsData.children) {
        loadedPositions.add({
          'position_name': position.child('position_name').value.toString(),
          'position_id': position.key.toString(),  // Store the key as position_id
        });
      }

      _positions = loadedPositions;
      notifyListeners();
    });
  }

  Future<void> deletePosition(String positionId) async {
    try {
      // Delete the position by its ID from Firebase
      await dref.child(positionId).remove();
      print('Position with ID $positionId deleted successfully.');

      // Fetch the updated positions list after deletion
      await fetchPositions();
    } catch (e) {
      print('Error deleting position: $e');
    }
  }


  Future<bool> checkForDuplicate(String position_name) async {
    try {
      print('I am in Duplicate Function');

      // Attempt to read the items node
      final  snapshot = await dref.get();

      // Debug the snapshot data
      print('Snapshot exists: ${snapshot.exists}');
      print('Snapshot value: ${snapshot.value}');

      // Check if the items node exists and is a Map
      if (snapshot.exists && snapshot.value is Map) {
        final Map<dynamic, dynamic> positions = snapshot.value as Map<dynamic, dynamic>;
        List<dynamic> list = positions.values.toList();

        print('Number of positions retrieved: ${list.length}');

        // Iterate through positions and check for duplicates
        for (var positions in list) {
          // Add debugging to see the structure of each positions
          print('Checking positions: $positions');

          // Ensure position_name  exist and compare them case-insensitively
          if (positions['position_name']?.toString().trim().toLowerCase() == position_name.trim().toLowerCase()) {
            print('Duplicate found: $positions');
            return true; // Duplicate found
          }
        }

        print('No duplicates found in the list.');
      } else {
        // If the position node doesn't exist or is not a Map, return false
        print("Positions node does not exist or is not a map. No duplicates found.");
      }
    } catch (e) {
      print("Error reading positions: $e");
    }

    return false; // No duplicates found
  }



  Future<String> savePosition(String position_name) async {
    // Check for duplicates before saving
    print('Starting to save position: $position_name');

    try {
      bool isDuplicate = await checkForDuplicate(position_name);

      if (isDuplicate) {
        print('Position already exists: $position_name');
        return "Position already exists"; // Return message if it's a duplicate
      }

      print('No duplicates found, proceeding to save.');

      try {
        String id = dref.push().key.toString(); // Create a new unique ID
        print('Generated ID: $id');

        await dref.child(id).set({
          'position_name': position_name,  // Save the original case-sensitive name
          'position_id': id,               // Save the unique ID
        });

        print('Position saved successfully.');

        await fetchPositions(); // Update the local list after adding the new position
        return "Position saved successfully"; // Return success message
      } catch (e) {
        print('Error saving Position: $e'); // Log the error for debugging
        return "Error saving position: $e";  // Return a friendly message including the error
      }
    } catch (e) {
      print('Error during position save process: $e');
      return "Error saving position: $e";
    }
  }

}
