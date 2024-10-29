import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/constants.dart';


class BluetoothPermission extends StatefulWidget {
  const BluetoothPermission({super.key});

  @override
  State<BluetoothPermission> createState() => _BluetoothPermissionState();
}

class _BluetoothPermissionState extends State<BluetoothPermission> {
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
              child: Image.asset('assets/images/bluetooth.jpg'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.12),
              child: const Text(
                'We will need your Bluetooth to be able to scan for the device',
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
                  backgroundColor: Colors.brown.shade600,
                  disabledForegroundColor: Colors.brown.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text(
                'accessBluetooth',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    if (statusBluetoothConnect.isDenied) {
      statusBluetoothConnect = await Permission.bluetoothConnect.request();
      if (statusBluetoothConnect.isGranted) {
        statusBluetoothConnect = PermissionStatus.granted;
        Permission.bluetoothScan.request();
        Fluttertoast.showToast(msg: 'bluetooth granted');
      }
    }
  }
}
