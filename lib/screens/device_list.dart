import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ble/device_connector.dart';
import '../ble/logger.dart';
import '../ble/scanner.dart';
import 'device_interaction_tab.dart';

part 'device_list.g.dart';

//ignore_for_file: annotate_overrides

class ScanningListScreen extends StatelessWidget {
  const ScanningListScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer5<BleScanner, ScannerState?,
          BleLogger, DeviceConnector, ConnectionStateUpdate>(
        builder: (_, bleScanner, bleScannerState, bleLogger, deviceConnector,
                connectionStateUpdate, __) =>
            Scanning(
          scannerState: bleScannerState ??
              const ScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector,
          connectionStatus: connectionStateUpdate.connectionState,
        ),
      );
}

@immutable
@FunctionalData()
class ScanningList extends $ScanningList {
  const ScanningList({
    required this.deviceId,
    required this.deviceConnector,
    required this.discoverServices,
  });

  final String deviceId;
  final DeviceConnector deviceConnector;
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;
}

class Scanning extends StatefulWidget {
  const Scanning({
    super.key,
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.deviceConnector,
    required this.connectionStatus,
  });

  final ScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final DeviceConnector deviceConnector;
  final DeviceConnectionState connectionStatus;
  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveRadiusAnimation;
  late Animation<double> _waveOpacityAnimation;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: height * 0.01),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated expanding wave
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: _waveRadiusAnimation.value * 2,
                          height: _waveRadiusAnimation.value * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepOrange.withOpacity(_waveOpacityAnimation.value),
                          ),
                        );
                      },
                    ),
                    // Bluetooth icon
                    const Icon(Icons.bluetooth, size: 70, color: Colors.deepOrange),
                  ],
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.bluetooth, size: 30, color: Colors.deepOrange),
                SizedBox(width: 10),
                Text(
                  "Available Devices",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Select a device to connect",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                ElevatedButton(
                  onPressed: _startScanning,
                  child: const Text(
                    'scan',
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.scannerState.discoveredDevices
                    .where((device) => device.name.isNotEmpty)
                    .length,
                itemBuilder: (context, index) {
                  final device = widget.scannerState.discoveredDevices
                      .where((device) => device.name.isNotEmpty)
                      .toList()[index];
              
                  return GestureDetector(
                    onTap: () {
                      widget.deviceConnector.connect(device.id).then(
                            (value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceInteractionTab(
                              device: device,
                              characteristic: QualifiedCharacteristic(
                                characteristicId: Uuid.parse(
                                    "0000ffe1-0000-1000-8000-00805f9b34fb"),
                                serviceId: Uuid.parse(
                                    "0000ffe0-0000-1000-8000-00805f9b34fb"),
                                deviceId: device.id,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.devices, size: 30, color: Colors.deepOrange.shade300),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.deepOrange.shade300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
              /*ListTile(
                title: Text(e.name),
                subtitle: Text(e.id),
                onTap: () {
                  // _connect();
                  widget.deviceConnector.connect(e.id).then(
                        (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceInteractionTab(
                          device: e,
                          characteristic: QualifiedCharacteristic(
                            characteristicId: Uuid.parse(
                                "0000ffe1-0000-1000-8000-00805f9b34fb"),
                            serviceId: Uuid.parse(
                                "0000ffe0-0000-1000-8000-00805f9b34fb"),
                            deviceId: e.id,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),*/

          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Repeats the wave animation continuously

    _waveRadiusAnimation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _waveOpacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _markAsNotFirstTime();
    super.initState();
    _startScanning();
  }

  void _markAsNotFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  void _startScanning() {
    if (!widget.scannerState.scanIsInProgress) {
      widget.startScan([]);
    }
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
}
