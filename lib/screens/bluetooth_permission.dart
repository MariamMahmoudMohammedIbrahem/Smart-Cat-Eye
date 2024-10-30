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
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.bluetooth,
                  size: width * .5,
                  color: Colors.deepOrange,
                ),
                const Positioned(
                  right: 8,
                  top: 8,
                  child: Icon(
                    Icons.help,
                    size: 30,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.12),
              child: Text(
                'We will need your Bluetooth to be able to scan for the device',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepOrange.shade100
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text(
                'accessBluetooth',
                style: TextStyle(color: Colors.deepOrange, fontSize: 18),
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
