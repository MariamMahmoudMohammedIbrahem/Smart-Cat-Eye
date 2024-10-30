import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/constants.dart';

class LocationPermission extends StatefulWidget {
  const LocationPermission({super.key});

  @override
  State<LocationPermission> createState() => _LocationPermissionState();
}

class _LocationPermissionState extends State<LocationPermission> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              color: Colors.deepOrange,
              size: width * .5,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .12),
              child: Text(
                'We will need your location to be able to connect to your device',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepOrange.shade100,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text(
                'accessLocation',
                style: TextStyle(color: Colors.deepOrange, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    if (statusLocation.isDenied) {
      statusLocation = await Permission.location.request();
      if (statusLocation.isGranted) {
        statusLocation = PermissionStatus.granted;
        Fluttertoast.showToast(msg: 'location granted');
      }
    }
  }
}
