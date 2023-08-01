import Flutter
import UIKit
import CoreBluetooth

public class IosPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate {
  private var bluetoothManager: CBCentralManager?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ios", binaryMessenger: registrar.messenger())
    let instance = IosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    instance.bluetoothManager = CBCentralManager(delegate: instance, queue: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initializeBluetooth": 
      initializeBluetooth()
      result(nil)
    case "startScanning":
      startScanning()
      result(nil)
    case "connectToDevice":
      guard let arguments = call.arguments as? [String: Any],
            let serviceUUID = arguments["serviceUUID"] as? String,
            let characteristicUUID = arguments["characteristicUUID"]  as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      connectToDevice(serviceUUID: serviceUUID, characteristicUUID: characteristicUUID)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
    // Method to handle Bluetooth state changes
    private func initializeBluetooth() {
         // Initialize the CBCentralManager
         bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }
   // MARK: - CBCentralManagerDelegate methods

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // Bluetooth is available and powered on
            // You can start scanning for devices or perform other Bluetooth operations here
            print("Bluetooth is powered on.")
        case .poweredOff:
            // Bluetooth is powered off
            // You may want to show an alert to the user to turn on Bluetooth
            print("Bluetooth is powered off.")
        case .unsupported:
            // Bluetooth is not supported on this device
            // You may want to inform the user that their device does not support Bluetooth
            print("Bluetooth is not supported.")
        case .unauthorized:
            // The app is not authorized to use Bluetooth
            // You may want to prompt the user to grant permission for Bluetooth usage
            print("Bluetooth usage is unauthorized.")
        default:
            break
        }
    }

    // Method to handle device discovery
    private func startScanning() {
        discoveredDevices = [:] // Clear previously discovered devices
        bluetoothManager?.scanForPeripherals(withServices: nil, options: nil)
    }

    // Method to handle device connection
    private func connectToDevice(serviceUUID: String, characteristicUUID: String) {
        // Implement device connection here
        // Call the callback function with the selected serviceUUID and characteristicUUID
        onDeviceSelected(serviceUUID: serviceUUID, characteristicUUID: characteristicUUID)
    }
    // MARK: - CBCentralManagerDelegate methods

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Handle Bluetooth state changes
        // ...
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      // Handle discovered devices and send the information back to Flutter using event channels
      discoveredDevices[peripheral.identifier.uuidString] = [
          "name": peripheral.name ?? "",
          "id": peripheral.identifier.uuidString,
          "rssi": RSSI.intValue
      ]

        sendDevicesDiscoveredEvent(devices: Array(discoveredDevices.values))
    }

  // Method to handle data sending
    private func sendData(data: String) {
        guard let peripheral = connectedPeripheral, let characteristic = connectedCharacteristic else {
            // Handle the case when no device is connected or no characteristic is selected.
            return
        }

        let dataToSend = data.data(using: .utf8)
        peripheral.writeValue(dataToSend!, for: characteristic, type: .withoutResponse)
    }

    // Helper method to handle characteristic discovery
    private func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Check if this is the characteristic you want to use
                if characteristic.uuid == selectedCharacteristicUUID {
                    // Save the connected characteristic
                    connectedCharacteristic = characteristic
                    break
                }
            }
        }

        // If the characteristic is found, you can now send data.
        if let characteristic = connectedCharacteristic {
            sendData(data: "Your data to send")
        }
    }

   // Method to handle data receiving
    private func startListeningForData() {
        guard let peripheral = connectedPeripheral, let characteristic = connectedCharacteristic else {
            // Handle the case when no device is connected or no characteristic is selected.
            return
        }

        // Set the characteristic's notification to true to enable data receiving
        peripheral.setNotifyValue(true, for: characteristic)
    }

    // Delegate method to handle characteristic value updates (data received)
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            // Handle the error
            print("Error updating characteristic value: \(error.localizedDescription)")
            return
        }

        // Check if this is the characteristic you want to receive data from
        if characteristic.uuid == selectedCharacteristicUUID {
            // Get the received data from the characteristic's value property
            if let data = characteristic.value {
                // Convert the data to a string, assuming it was sent as a UTF-8 encoded string
                if let receivedData = String(data: data, encoding: .utf8) {
                    // Handle the received data
                    print("Received data: \(receivedData)")
                }
            }
        }
    }

        // Helper method to send devicesDiscovered event to Flutter
    private func sendDevicesDiscoveredEvent(devices: [[String: Any]]) {
        let args: [String: Any] = ["devices": devices]
        let channel = FlutterEventChannel(name: "bluetooth_ios_plugin/devicesDiscovered", binaryMessenger: registrar.messenger())
        channel.setStreamHandler(FlutterStreamHandlerWrapper(handler: self))
        channel.invokeMethod("devicesDiscovered", arguments: args)
    }

    // Callback function to be called when the user selects a device
    private func onDeviceSelected(serviceUUID: String, characteristicUUID: String) {
        let args: [String: Any] = [
            "serviceUUID": serviceUUID,
            "characteristicUUID": characteristicUUID,
        ]
        let channel = FlutterMethodChannel(name: "ios", binaryMessenger: registrar.messenger())
        channel.invokeMethod("onDeviceSelected", arguments: args)
    }

