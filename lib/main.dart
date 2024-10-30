import 'package:cat/screens/ble_status_screen.dart';
import 'package:cat/screens/bluetooth_permission.dart';
import 'package:cat/screens/device_list.dart';
import 'package:cat/screens/location_permission.dart';
import 'package:cat/screens/permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'ble/logger.dart';
import 'ble/scanner.dart';
import 'ble/device_connector.dart';
import 'ble/device_interactor.dart';
import 'ble/status_monitor.dart';
import 'constants/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  statusLocation = await Permission.location.status;
  statusBluetoothConnect = await Permission.bluetoothConnect.status;
  statusNotification = await Permission.notification.status;
  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = StatusMonitor(ble);
  final connector = DeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = DeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      await ble.discoverAllServices(deviceId);
      return ble.getDiscoveredServices(deviceId);
    },
    readCharacteristic: ble.readCharacteristic,
    writeWithResponse: ble.writeCharacteristicWithResponse,
    writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: ble.subscribeToCharacteristic,
    logMessage: bleLogger.addToLog,
  );
  runApp(MultiProvider(
    providers: [
      Provider.value(value: scanner),
      Provider.value(value: monitor),
      Provider.value(value: connector),
      Provider.value(value: serviceDiscoverer),
      Provider.value(value: bleLogger),
      StreamProvider<ScannerState?>(
        create: (_) => scanner.state,
        initialData: const ScannerState(
          discoveredDevices: [],
          scanIsInProgress: false,
        ),
      ),
      StreamProvider<BleStatus?>(
        create: (_) => monitor.state,
        initialData: BleStatus.unknown,
      ),
      ChangeNotifierProvider(
        create: (context) => PermissionProvider(),
      ),
      StreamProvider<ConnectionStateUpdate>(
        create: (_) => connector.state,
        initialData: const ConnectionStateUpdate(
          deviceId: 'Unknown device',
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Insulin',
      color: Colors.blue.shade200,
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      home: const MyApp(),
    ),
  ));
  FlutterReactiveBle();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat\'s Eye',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepOrange,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepOrange,
          onPrimary: Colors.white,
          secondary: Colors.deepOrange,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: TextTheme(
          bodyMedium: const TextStyle(color: Colors.white, fontSize: 16),
          bodySmall: TextStyle(color: Colors.grey[300]),
        ),
        switchTheme: SwitchThemeData(
          splashRadius: 50.0,
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.deepOrange;
            }
            return Colors.grey.shade300;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.deepOrange.shade300;
            }
            return Colors.grey.shade800;
          }),
        ),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleStatus?, PermissionProvider>(
        builder: (_, status, permission, __) {
          if (status == BleStatus.ready &&
              permission.bluetoothStatus.isGranted &&
              permission.locationStatus.isGranted) {
            return const ScanningListScreen();
          } else if (permission.locationStatus.isDenied) {
            permission.requestLocationPermission();
            return const LocationPermission();
          } else if (permission.bluetoothStatus.isDenied) {
            permission.requestBluetoothPermission();
            return const BluetoothPermission();
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
