
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/constants.dart';


class PermissionProvider extends ChangeNotifier {
  // Define the permissions you want to manage
  PermissionStatus _locationStatus = statusLocation;
  PermissionStatus _bluetoothStatus = statusBluetoothConnect;
  PermissionStatus _notificationStatus = statusBluetoothConnect;

  // Getters for permission statuses
  PermissionStatus get locationStatus => _locationStatus;
  PermissionStatus get bluetoothStatus => _bluetoothStatus;
  PermissionStatus get notificationStatus => _notificationStatus;

  // Function to request location permission
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.status;
    _locationStatus = status;
    notifyListeners();
  }

  // Function to request bluetooth permission
  Future<void> requestBluetoothPermission() async {
    final status = await Permission.bluetoothConnect.status;
    _bluetoothStatus = status;
    notifyListeners();
  }
  // Function to request bluetooth permission
  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    _notificationStatus = status;
    notifyListeners();
  }
}