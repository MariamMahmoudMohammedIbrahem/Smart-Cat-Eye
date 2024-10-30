# Smart Cat Eye

## Overview
Smart Cat Eye is a mobile application designed to interface with hardware devices via Bluetooth Low Energy (BLE). The app allows users to send and receive settings, enabling seamless interaction with the connected devices. The user interface dynamically updates based on the responses received from the hardware, ensuring a responsive and intuitive experience.

## Features
- BLE Connectivity: Establish a stable connection with BLE-enabled hardware devices.
- Dynamic UI: The user interface updates in real-time based on device responses.
- Settings Management: Easily send and receive settings to and from the hardware.
- User-Friendly Design: Intuitive navigation and layout for a smooth user experience.

## Usage
- Connect to a Device:
    - Open the app and scan for available BLE devices.
    - Select a device from the list to establish a connection.

- Send Settings:
    - Adjust the settings as desired and send them to the hardware.

- Receive Updates:

    - Monitor the app for updates from the hardware.
    - The UI will automatically reflect any changes or responses.

## Architecture
- Frontend: Built with Flutter, leveraging Dart for a smooth cross-platform experience.
- BLE Communication: Utilizes the Flutter reactive_ble package for handling Bluetooth communications.

## License
This project is licensed under the MIT License. See the LICENSE file for details.