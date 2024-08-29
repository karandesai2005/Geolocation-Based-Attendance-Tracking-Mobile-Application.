import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceTracker {
  final double officeLatitude = 18.5412214;  
  final double officeLongitude = 73.7274563;
  final double radius = 200000; // Radius in meters

  Position? currentPosition;
  bool isInsideOffice = false;
  StreamSubscription<Position>? positionStreamSubscription;

  Future<void> markPresent(Position position) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final attendanceData = {
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'status': 'present',
      };

      await FirebaseFirestore.instance.collection('attendance').add(attendanceData);
    } catch (e) {
      print('Error marking present: $e');
    }
  }

  Future<void> markAbsent(Position position) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final attendanceData = {
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'status': 'absent',
      };

      await FirebaseFirestore.instance.collection('attendance').add(attendanceData);
    } catch (e) {
      print('Error marking absent: $e');
    }
  }

  void startTracking() async {
    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('Location permissions are denied');
        return;
      }

      // Stream to continuously monitor location
      positionStreamSubscription = Geolocator.getPositionStream().listen((position) {
        currentPosition = position;
        double distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          officeLatitude,
          officeLongitude,
        );

        // ... rest of your tracking logic

        // Inside the if-else conditions for check-in/check-out:
          if (distance <= radius && !isInsideOffice) {
            // Check-in logic
            isInsideOffice = true;
            markPresent(currentPosition!); // Call markPresent
          } else if (distance > radius && isInsideOffice) {
            // Check-out logic
            isInsideOffice = false;
            markAbsent(currentPosition!); // Call markAbsent
          }
        });
      } catch (e) {
        print('Error starting tracking: $e');
      }
    }

    void stopTracking() {
      positionStreamSubscription?.cancel();
    }
  }
  