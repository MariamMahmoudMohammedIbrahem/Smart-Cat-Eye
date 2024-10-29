import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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
          writeWithResponse: interactor.writeCharacteristicWithResponse,
          writeWithoutResponse: interactor.writeCharacteristicWithoutResponse,
          readCharacteristic: interactor.readCharacteristic,
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
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.readCharacteristic,
    required this.subscribeToCharacteristic,
    required this.device,
    super.key,
  });
  final DeviceInteractionViewModel viewModel;

  final QualifiedCharacteristic characteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
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
                    value: isOn,
                    onChanged: (value) {
                      setState(() {
                        isOn =
                            value; //shouldn't be changed here but inside the listen
                        widget.subscribeToCharacteristic(widget.characteristic);
                        widget.writeWithoutResponse(widget.characteristic,
                            value ? switchOn : switchOff);
                        widget.writeWithoutResponse(
                            widget.characteristic, requestStatus);
                      });
                    },
                  ),
                ],
              ),

              Visibility(
                visible: isOn,
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
                        Icon(
                          isSynced ? Icons.check_circle : Icons.error,
                          color: isSynced
                              ? Colors.deepOrange.shade300
                              : Colors.red,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOn/* && isSynced*/)
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
                          Slider(
                            value: sequentialDelay,
                            min: 0,
                            max: 1000,
                            onChanged: (value) {
                              setState(() {
                                sequentialDelay = value;
                                int checkSum = 0x02 + 0x01 + value.toInt();
                                widget.subscribeToCharacteristic(
                                    widget.characteristic);
                                widget.writeWithoutResponse(
                                    widget.characteristic, [
                                  0xAA,
                                  0x02,
                                  0x01,
                                  value.toInt(),
                                  checkSum,
                                  0xBB
                                ]);
                              });
                            },
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
                                  widget.subscribeToCharacteristic(
                                      widget.characteristic);
                                  widget.writeWithoutResponse(
                                      widget.characteristic,
                                      [0xAA, 0x03, 0x00, 0x00, 0x03, 0xBB]);
                                },
                                child: const Text('default'),
                              ),
                            ],
                          ),
                          Slider(
                            value: toggleDelay,
                            min: 0,
                            max: 1000,
                            onChanged: (value) {
                              setState(() {
                                toggleDelay = value;
                                int checkSum = 0x03 + 0x01 + value.toInt();
                                widget.subscribeToCharacteristic(
                                    widget.characteristic);
                                widget.writeWithoutResponse(
                                    widget.characteristic, [
                                  0xAA,
                                  0x03,
                                  0x01,
                                  toggleDelay.toInt(),
                                  checkSum,
                                  0xBB
                                ]);
                              });
                            },
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
                        setState(() {
                          selectedPair = 0;
                        });
                        // setState(() {
                        widget.subscribeToCharacteristic(widget.characteristic);
                        widget.writeWithoutResponse(widget.characteristic,
                            [0xAA, 0x04, 0x01, 0x00, 0x05, 0xBB]);
                        // });
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
                        setState(() {
                          selectedPair = 1;
                        });
                        widget.subscribeToCharacteristic(widget.characteristic);
                        widget.writeWithoutResponse(widget.characteristic,
                            [0xAA, 0x04, 0x01, 0x01, 0x06, 0xBB]);
                        // Add command to select one LED pair here
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
                        setState(() {
                          selectedPair = 2;
                        });
                        widget.subscribeToCharacteristic(widget.characteristic);
                        widget.writeWithoutResponse(widget.characteristic,
                            [0xAA, 0x04, 0x01, 0x02, 0x07, 0xBB]);
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
  void dispose() {
    widget.viewModel.deviceConnector.disconnect(widget.device.id);
    subscribeStream?.cancel();
    super.dispose();
  }

  Future<void> subscribeCharacteristic() async {
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      if (event == success) {
        isOn = true;
        //mode
        //delay
        //led pair
      } else if (event == error) {
      } else if (event == inputDataError) {
      } else {
        isOn = true;
        //mode
        //delay
        //led pair
        isSynced = true;
      }
    });
  }
}
