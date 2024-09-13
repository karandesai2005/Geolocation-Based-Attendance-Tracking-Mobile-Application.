import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'attendance_tracker.dart'; // Import the AttendanceTracker class
// Import the LoginScreen class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  final AttendanceTracker attendanceTracker;

  const HomePage({super.key, required this.attendanceTracker});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCheckingIn = false; // Flag to indicate check-in process
  final List<AttendanceData> _attendanceHistory = []; // List to store attendance history

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
        18.5412214, // Replace with your office latitude
        73.7274563, // Replace with your office longitude
      );

      // Check if user is within the radius
      if (distance <= 20000) {
        // Mark user as present in Firestore (implementation in AttendanceTracker)
        widget.attendanceTracker.markPresent(currentPosition);

        // Add attendance data to history
        _attendanceHistory.add(
          AttendanceData(
            status: 'present',
            timestamp: FieldValue.serverTimestamp(),
            latitude: currentPosition.latitude,
            longitude: currentPosition.longitude,
          ),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in successful!'),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not within the office radius.'),
          ),
        );
      }

      setState(() {});
    } else {
      // Show error message for denied permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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

      // Add attendance data to history
      _attendanceHistory.add(
        AttendanceData(
          status: 'absent',
          timestamp: FieldValue.serverTimestamp(),
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
        ),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Log out the user and navigate to login screen
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushReplacementNamed(context, '/login');
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Please Check In',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCheckingIn ? null : _checkIn,
              child: Text(_isCheckingIn ? 'Checking In...' : 'Check In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.attendanceTracker.isInsideOffice ? null : _checkOut,
              child: const Text('Check Out'),
            ),
            const SizedBox(height: 20),
            const Text('Attendance History:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _attendanceHistory.length,
                itemBuilder: (context, index) {
                  final attendance = _attendanceHistory[index];
                  return ListTile(
                    title: Text('Status: ${attendance.status}'),
                    subtitle: Text('Timestamp: ${attendance.timestamp}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define a class to represent attendance data
class AttendanceData {
  final String status;
  final FieldValue timestamp;
  final double latitude;
  final double longitude;

  AttendanceData({
    required this.status,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });
}
