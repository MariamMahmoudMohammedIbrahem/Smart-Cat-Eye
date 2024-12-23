import 'dart:async';

import 'package:cat/ble/reactive_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleScanner implements ReactiveState<ScannerState> {
  BleScanner({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;
  final StreamController<ScannerState> _stateStreamController =
  StreamController();

  final _devices = <DiscoveredDevice>[];

  @override
  Stream<ScannerState> get state => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    _logMessage('Start ble discovery');
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
          ///TODO: check if the ble name will be insulin
          // if (device.name == 'insulin') {
          // stopScan();
          // scanStopped = true;
          final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
          if (knownDeviceIndex >= 0) {
            _devices[knownDeviceIndex] = device;
          } else {
            _devices.add(device);
          }
          _pushState();
          // }
        }, onError: (Object e) => _logMessage('Device scan fails with error: $e'));
    Future.delayed(const Duration(seconds: 5), () {
      stopScan();
    });
    _pushState();
  }

  void _pushState() {
    _stateStreamController.add(
      ScannerState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      ),
    );
  }

  Future<void> stopScan() async {
    _logMessage('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  StreamSubscription? _subscription;
}

@immutable
class ScannerState {
  const ScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}