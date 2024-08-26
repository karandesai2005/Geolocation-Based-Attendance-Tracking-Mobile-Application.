import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'attendance_tracker.dart'; // Import the AttendanceTracker class

class HomePage extends StatefulWidget {
  final AttendanceTracker attendanceTracker;

  const HomePage({Key? key, required this.attendanceTracker}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCheckingIn = false; // Flag to indicate check-in process

  Future<void> _checkIn() async {
    // Request location permission if not granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Check if permission is granted
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _isCheckingIn = true;
      });

      // Get current location
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Calculate distance from office location (replace with your coordinates)
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        37.7749, // Replace with your office latitude
        -122.4194, // Replace with your office longitude
      );

      // Check if user is within the radius
      if (distance <= 200) {
        // Mark user as present in Firestore (implementation in AttendanceTracker)
        widget.attendanceTracker.markPresent(currentPosition);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in successful!'),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are not within the office radius.'),
          ),
        );
      }

      setState(() {
        _isCheckingIn = false;
      });
    } else {
      // Show error message for denied permission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission is required for check-in.'),
        ),
      );
    }
  }

  Future<void> _checkOut() async {
    // Request location permission if not granted (similar to _checkIn)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Check if permission is granted
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Get current location
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Calculate distance from office location (already implemented in _checkIn)

      // Call AttendanceTracker method to mark check-out in Firestore
      await widget.attendanceTracker.markAbsent(currentPosition);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-out successful!'),
        ),
      );
    } else {
      // Show error message for denied permission (already implemented in _checkIn)
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isCheckingIn ? null : _checkIn,
              child: Text(_isCheckingIn ? 'Checking In...' : 'Check In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _checkOut(), // Implement checkOut logic
              child: Text('Check Out'),
            ),
          ],
        ),
      ),
    );
  }
}
