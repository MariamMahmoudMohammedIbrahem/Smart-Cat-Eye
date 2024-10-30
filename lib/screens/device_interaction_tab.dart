import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../ble/device_connector.dart';
import '../ble/device_interactor.dart';
import '../constants/constants.dart';

part 'device_interaction_tab.g.dart';

class DeviceInteractionTab extends StatelessWidget {
  const DeviceInteractionTab({
    required this.device,
    required this.characteristic,
    super.key,
  });
  final DiscoveredDevice device;
  final QualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context) => Consumer4<DeviceConnector,
          ConnectionStateUpdate, DeviceInteractor, DeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                interactor, __) =>
            Connecting(
          viewModel: DeviceInteractionViewModel(
            deviceId: device.id,
            connectableStatus: device.connectable,
            connectionStatus: connectionStateUpdate.connectionState,
            deviceConnector: deviceConnector,
            discoverServices: () =>
                serviceDiscoverer.discoverServices(device.id),
          ),
          characteristic: characteristic,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          subscribeToCharacteristic: interactor.subScribeToCharacteristic,
          device: device,
        ),
      );
}

// @immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
  });

  @override
  final String deviceId;
  @override
  final Connectable connectableStatus;
  @override
  final DeviceConnectionState connectionStatus;
  @override
  final DeviceConnector deviceConnector;
  @override
  @CustomEquality(Ignore())
  final Future<List<Service>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class Connecting extends StatefulWidget {
  const Connecting({
    required this.viewModel,
    required this.characteristic,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
    required this.device,
    super.key,
  });
  final DeviceInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;
  final DiscoveredDevice device;

  @override
  State<Connecting> createState() => _ConnectingState();
}

class _ConnectingState extends State<Connecting> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.deepOrange,
        title: Text(
          widget.device.name,
          style: const TextStyle(color: Colors.deepOrange),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                if (widget.viewModel.connectionStatus ==
                        DeviceConnectionState.connecting ||
                    widget.viewModel.connectionStatus ==
                        DeviceConnectionState.connected) {
                  widget.viewModel.disconnect();
                } else if (widget.viewModel.connectionStatus ==
                        DeviceConnectionState.disconnecting ||
                    widget.viewModel.connectionStatus ==
                        DeviceConnectionState.disconnected) {
                  widget.viewModel.connect();
                }
              },
              child: Text((widget.viewModel.connectionStatus ==
                      DeviceConnectionState.connected)
                  ? 'unpair'
                  : (widget.viewModel.connectionStatus ==
                          DeviceConnectionState.connecting)
                      ? 'pairing'
                      : (widget.viewModel.connectionStatus ==
                              DeviceConnectionState.disconnected)
                          ? 'pair'
                          : 'unpairing'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: width * .07),
        child: Center(
          child: ListView(
            children: [
              ///*mode_selection**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "System Mode: ",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade300),
                  ),
                  Switch(
                    value: isOn &&
                        widget.viewModel.connectionStatus ==
                            DeviceConnectionState.connected,
                    onChanged: isToastVisible
                        ? (value) {}
                        : (value) {
                            setState(() {
                              if (widget.viewModel.connectionStatus ==
                                  DeviceConnectionState.connected) {
                                subscribeCharacteristic(
                                    'request the status of the device again');
                                widget.writeWithoutResponse(
                                    widget.characteristic,
                                    value ? switchOn : switchOff);
                              } else {
                                showToast(
                                    'you must be connected to the device to be able to send the data',
                                    Toast.LENGTH_LONG);
                              }
                            });
                          },
                  ),
                ],
              ),

              Visibility(
                visible: isOn &&
                    widget.viewModel.connectionStatus ==
                        DeviceConnectionState.connected,
                child: Column(
                  children: [
                    Divider(
                      color: Colors.deepOrange.shade200,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sync Status: ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade300),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            subscribeCharacteristic(
                                'try sending the settings again');
                            widget.writeWithoutResponse(
                                widget.characteristic, requestStatus);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.sync,
                                color: Colors.deepOrange.shade300,
                                size: 15,
                              ),
                              Text(
                                'sync',
                                style: TextStyle(
                                  color: Colors.deepOrange.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOn &&
                  isSynced &&
                  widget.viewModel.connectionStatus ==
                      DeviceConnectionState.connected)
                Column(
                  children: [
                    ///*delay_adjustment**
                    Divider(
                      color: Colors.deepOrange.shade200,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Modes: ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade300),
                        ),
                        DropdownButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          value: selectedMode,
                          items: const [
                            DropdownMenuItem(
                              value: "Sequential Delay",
                              child: Text("Sequential Delay"),
                            ),
                            DropdownMenuItem(
                              value: "Toggle Delay",
                              child: Text("Toggle Delay"),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMode = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                    if (selectedMode == "Sequential Delay")
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Sequential Delay: ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade300),
                              ),
                              Text(
                                "${sequentialDelay.toInt()} ms",
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$sequentialSlider ms'),
                              Expanded(
                                child: Slider(
                                  value: sequentialSlider.toDouble(),
                                  min: 0,
                                  max: 1000,
                                  onChanged: (value) {
                                    setState(() {
                                      sequentialSlider = value.toInt();
                                    });
                                    debounce?.cancel();
                                    debounce =
                                        Timer(const Duration(seconds: 1), () {
                                      int checkSum =
                                          0x02 + 0x01 + sequentialSlider;
                                      subscribeCharacteristic(
                                          'try sending the settings again');

                                      ///slider
                                      String hexString = sequentialDelay
                                          .toRadixString(16)
                                          .padLeft(4, '0')
                                          .toUpperCase();
                                      widget.writeWithoutResponse(
                                          widget.characteristic, [
                                        0xAA,
                                        0x02,
                                        0x02,
                                        int.parse(hexString.substring(0, 2),
                                            radix: 16),
                                        int.parse(hexString.substring(2, 4),
                                            radix: 16),
                                        checkSum,
                                        0xBB,
                                      ]);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    if (selectedMode == "Toggle Delay")
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Toggle Delay: ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange.shade300),
                                  ),
                                  Text(
                                    "${toggleDelay.toInt()} ms",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  subscribeCharacteristic(
                                      'try sending the settings again');
                                  widget.writeWithoutResponse(
                                      widget.characteristic,
                                      [0xAA, 0x03, 0x00, 0x00, 0x03, 0xBB]);
                                },
                                child: const Text('default'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$toggleSlider ms'),
                              Expanded(
                                child: Slider(
                                  value: toggleSlider.toDouble(),
                                  min: 0,
                                  max: 1000,
                                  onChanged: (value) {
                                    setState(() {
                                      toggleSlider = value.toInt();
                                    });
                                    debounce?.cancel();
                                    debounce =
                                        Timer(const Duration(seconds: 1), () {
                                      int checkSum = 0x02 + 0x01 + toggleSlider;
                                      subscribeCharacteristic(
                                          'try sending the settings again');

                                      ///slider
                                      String hexString = toggleDelay
                                          .toRadixString(16)
                                          .padLeft(4, '0')
                                          .toUpperCase();
                                      widget.writeWithoutResponse(
                                          widget.characteristic, [
                                        0xAA,
                                        0x02,
                                        0x02,
                                        int.parse(hexString.substring(0, 2),
                                            radix: 16),
                                        int.parse(hexString.substring(2, 4),
                                            radix: 16),
                                        checkSum,
                                        0xBB,
                                      ]);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    Divider(
                      color: Colors.deepOrange.shade200,
                    ),

                    ///*led_pair_selection**
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Led Pair: ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade300),
                      ),
                    ),
                    RadioListTile<int>(
                      title: Text(
                        "Default Pair",
                        style: TextStyle(
                            color: selectedPair == 0
                                ? Colors.deepOrange.shade300
                                : Colors.white),
                      ),
                      value: 0,
                      groupValue: selectedPair,
                      onChanged: (value) {
                        subscribeCharacteristic(
                            'try sending the settings again');
                        widget.writeWithoutResponse(
                            widget.characteristic, ledPair0);
                      },
                    ),
                    RadioListTile<int>(
                      title: Text(
                        "One Pair",
                        style: TextStyle(
                            color: selectedPair == 1
                                ? Colors.deepOrange.shade300
                                : Colors.white),
                      ),
                      value: 1,
                      groupValue: selectedPair,
                      onChanged: (value) {
                        subscribeCharacteristic(
                            'try sending the settings again');
                        widget.writeWithoutResponse(
                            widget.characteristic, ledPair1);
                      },
                    ),
                    RadioListTile<int>(
                      title: Text(
                        "Both Pairs",
                        style: TextStyle(
                            color: selectedPair == 2
                                ? Colors.deepOrange.shade300
                                : Colors.white),
                      ),
                      value: 2,
                      groupValue: selectedPair,
                      onChanged: (value) {
                        subscribeCharacteristic(
                            'try sending the settings again');
                        widget.writeWithoutResponse(
                            widget.characteristic, ledPair2);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    monitorDeviceStatus();
    super.initState();
  }

  Future<void> subscribeCharacteristic(String msg) async {
    receiving = false;
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      if (event.length == 3 && event[1] == success[1]) {
        setState(() {
          isOn = true;
        });
        widget.writeWithoutResponse(widget.characteristic, requestStatus);
        showToast('send successfully', Toast.LENGTH_SHORT);
      } else if (event.length == 3 && event[1] == error[1]) {
        showToast(
            'error happened while sending the settings', Toast.LENGTH_SHORT);
        setState(() {
          receiving = true;
        });
      } else if (event.length == 3 && event[1] == inputDataError[1]) {
        showToast('wrong data', Toast.LENGTH_SHORT);
        setState(() {
          receiving = true;
        });
      } else if (event[1] == 0x15) {
        showToast('synced successfully', Toast.LENGTH_SHORT);
        setState(() {
          isSynced = true;
          isOn = event[3] == 1 ? true : false;
          selectedMode = event[4] == 0x02 ? 'Sequential Delay' : 'Toggle Delay';
          if (event[4] == 0x02) {
            selectedMode = 'Sequential Delay';
            sequentialDelay = convertToInteger([event[5], event[6]]);
            sequentialSlider = sequentialDelay;
          } else if (event[4] == 0x03) {
            selectedMode = 'Toggle Delay';
            toggleDelay = convertToInteger([event[5], event[6]]);
            toggleSlider = toggleDelay;
          }
          selectedPair = event[7];
          receiving = true;
        });
      }
    });
    if (!receiving) {
      Future.delayed(const Duration(seconds: 3)).then((value) => {
            if (!receiving)
              {
                showToast(msg, Toast.LENGTH_SHORT),
                setState(() {
                  sequentialSlider = sequentialDelay;
                  toggleSlider = toggleDelay;
                }),
              }
          });
    }
  }

  int convertToInteger(List<int> bytes) {
    if (bytes.length != 2) {
      throw ArgumentError("The list must contain exactly 2 bytes.");
    }
    for (int byte in bytes) {
      if (byte < 0 || byte > 255) {
        throw RangeError("Each byte should be between 0 and 255.");
      }
    }
    return (bytes[0] << 8) | bytes[1];
  }

  void monitorDeviceStatus() {
    connectionStatusStream.listen((status) {
      if (status == DeviceConnectionState.connected) {
        subscribeCharacteristic('request the status of the device again');
        widget.writeWithoutResponse(widget.characteristic, requestStatus);
      }
    }, onError: (error) {
      print("Error in connection status stream: $error");
    });
  }

  void showToast(String msg, Toast? length) {
    if (isToastVisible) return;

    setState(() {
      isToastVisible = true;
    });

    Fluttertoast.showToast(
            msg: msg,
            toastLength: length,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.deepOrange,
            textColor: Colors.black)
        .then((_) {
      Future.delayed(const Duration(seconds: 1)).then(
        (value) => setState(() {
          isToastVisible = false;
        }),
      );
    });
  }

  @override
  void dispose() {
    widget.viewModel.deviceConnector.disconnect(widget.device.id);
    subscribeStream?.cancel();
    debounce?.cancel();
    super.dispose();
  }
}
