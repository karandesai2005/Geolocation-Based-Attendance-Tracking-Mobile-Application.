import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AttendanceTracker {
  final double officeLatitude = 37.7749; // Replace with your office latitude
  final double officeLongitude = -122.4194; // Replace with your office longitude
  final double radius = 200; // Radius in meters

  Position? currentPosition;
  bool isInsideOffice = false;

  // ... other variables and methods

  void startTracking() {
    // Request location permissions
    Geolocator.requestPermission();

    // Stream to continuously monitor location
    Geolocator.getPositionStream().listen((position) {
      currentPosition = position;
      double distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        officeLatitude,
        officeLongitude,
      );

      if (distance <= radius && !isInsideOffice) {
        // Check-in logic
        isInsideOffice = true;
        // Store check-in time and location in database
      } else if (distance > radius && isInsideOffice) {
        // Check-out logic
        isInsideOffice = false;
        // Store check-out time and location in database
      }
    });
  }
}