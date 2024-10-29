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
            SizedBox(
              width: width,
              child: Image.asset('assets/images/location.jpg'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .12),
              child: const Text(
                'We will need your location to be able to connect to your device',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  backgroundColor: Colors.brown.shade500, //replace with 855A2D
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text(
                'accessLocation',
                style: TextStyle(color: Colors.white, fontSize: 18),
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
