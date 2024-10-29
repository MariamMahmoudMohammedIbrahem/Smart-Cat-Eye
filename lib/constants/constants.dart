import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

PermissionStatus statusLocation = PermissionStatus.denied;
PermissionStatus statusBluetoothConnect = PermissionStatus.denied;
PermissionStatus statusNotification = PermissionStatus.denied;

///*packets commands**
List<int> switchOn = [0xAA, 0x01, 0x01, 0x01, 0x03, 0xBB];
List<int> switchOff = [0xAA, 0x01, 0x01, 0x00, 0x02, 0xBB];
List<int> sequentialMode = [0xAA, 0x02, 0x01, 0x64, 0x67, 0xBB]; //0x64 is 100ms
List<int> toggleMode = [0xAA, 0x03, 0x00, 0x00, 0x03, 0xBB];
List<int> ledPair0 = [0xAA, 0x04, 0x01, 0x00, 0x05, 0xBB];
List<int> ledPair1 = [0xAA, 0x04, 0x01, 0x01, 0x06, 0xBB];
List<int> ledPair2 = [0xAA, 0x04, 0x01, 0x02, 0x07, 0xBB];
List<int> requestStatus = [0xAA, 0x05, 0x05, 0xBB]; // make sure that it is the right packet'

List<int> success = [0xAA, 0x01, 0xBB];
List<int> error = [0xAA, 0x02, 0xBB];
List<int> inputDataError = [0xAA, 0x03, 0xBB];

bool isOn = false;
bool isSynced = false;
double sequentialDelay = 100.0;
double toggleDelay = 100.0;
int selectedPair = 0; // 0: Default, 1: One pair, 2: Both pairs

const String currentMode = "Sequential";
const int delay = 300;
const String activePair = "One Pair";
String selectedMode = 'Sequential Delay';

StreamSubscription<List<int>>? subscribeStream;