// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_list.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

abstract class $ScanningList {
  const $ScanningList();

  String get deviceId;
  DeviceConnector get deviceConnector;
  Future<List<DiscoveredService>> Function() get discoverServices;

  ScanningList copyWith({
    String? deviceId,
    DeviceConnector? deviceConnector,
    Future<List<DiscoveredService>> Function()? discoverServices,
  }) =>
      ScanningList(
        deviceId: deviceId ?? this.deviceId,
        deviceConnector: deviceConnector ?? this.deviceConnector,
        discoverServices: discoverServices ?? this.discoverServices,
      );

  ScanningList copyUsing(
      void Function(DeviceList$Change change) mutator) {
    final change = DeviceList$Change._(
      deviceId,
      deviceConnector,
      discoverServices,
    );
    mutator(change);
    return ScanningList(
      deviceId: change.deviceId,
      deviceConnector: change.deviceConnector,
      discoverServices: change.discoverServices,
    );
  }

  @override
  String toString() =>
  "DeviceList(deviceId: $deviceId, deviceConnector: $deviceConnector, discoverServices: $discoverServices)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is ScanningList &&
          other.runtimeType == runtimeType &&
          deviceId == other.deviceId &&
          deviceConnector == other.deviceConnector &&
          const Ignore().equals(discoverServices, other.discoverServices);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + deviceId.hashCode;
    result = 37 * result + deviceConnector.hashCode;
    result = 37 * result + const Ignore().hash(discoverServices);
    return result;
  }
}

class DeviceList$Change {
  DeviceList$Change._(
      this.deviceId,
      this.deviceConnector,
      this.discoverServices,
      );

  String deviceId;
  DeviceConnector deviceConnector;
  Future<List<DiscoveredService>> Function() discoverServices;
}

// ignore: avoid_classes_with_only_static_members
class DeviceList$ {
  static final deviceId = Lens<ScanningList, String>(
        (deviceIdContainer) => deviceIdContainer.deviceId,
        (deviceIdContainer, deviceId) =>
        deviceIdContainer.copyWith(deviceId: deviceId),
  );
  static final deviceConnector =
  Lens<ScanningList, DeviceConnector>(
        (deviceConnectorContainer) => deviceConnectorContainer.deviceConnector,
        (deviceConnectorContainer, deviceConnector) =>
        deviceConnectorContainer.copyWith(deviceConnector: deviceConnector),
  );

  static final discoverServices = Lens<ScanningList,
      Future<List<DiscoveredService>> Function()>(
        (discoverServicesContainer) => discoverServicesContainer.discoverServices,
        (discoverServicesContainer, discoverServices) =>
        discoverServicesContainer.copyWith(discoverServices: discoverServices),
  );
}