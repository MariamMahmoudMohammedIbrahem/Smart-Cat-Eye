import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble/device_connector.dart';

PermissionStatus statusLocation = PermissionStatus.denied;
PermissionStatus statusBluetoothConnect = PermissionStatus.denied;
PermissionStatus statusNotification = PermissionStatus.denied;

///*packets commands**
List<int> switchOn = [0xAA, 0x01, 0x01, 0x01, 0x03, 0xBB];
List<int> switchOff = [0xAA, 0x01, 0x01, 0x00, 0x02, 0xBB];
List<int> ledPair0 = [0xAA, 0x04, 0x01, 0x00, 0x05, 0xBB];
List<int> ledPair1 = [0xAA, 0x04, 0x01, 0x01, 0x06, 0xBB];
List<int> ledPair2 = [0xAA, 0x04, 0x01, 0x02, 0x07, 0xBB];
List<int> requestStatus = [0xAA, 0x05, 0x05, 0xBB]; // make sure that it is the right packet'

List<int> success = [0xAA, 0x01, 0xBB];
List<int> error = [0xAA, 0x02, 0xBB];
List<int> inputDataError = [0xAA, 0x03, 0xBB];

bool isOn = false;
bool isSynced = false;
int sequentialDelay = 100;
int sequentialSlider = 100;
int toggleDelay = 100;
int toggleSlider = 100;
int selectedPair = 0; // 0: Default, 1: One pair, 2: Both pairs
String selectedMode = 'Sequential Delay';
Timer? debounce;
bool isToastVisible = false;

StreamSubscription<List<int>>? subscribeStream;
bool receiving = false;
Stream<DeviceConnectionState> get connectionStatusStream => connectionStatusController.stream;
