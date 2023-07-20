import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var serviceUUID: CBUUID?
    private var characteristicUUID: CBUUID?
    private var onDataReceivedEventSink: FlutterEventSink?
    private var onErrorEventSink: FlutterEventSink?
    private var devicesEventSink: FlutterEventSink?
    private var devices: [CBPeripheral] = []

    init(serviceUUID: CBUUID, characteristicUUID: CBUUID) {
        super.init()
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            emitDeviceDiscovery([])
        }
    }

    func startScan(duration: Int) {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
            self.stopScan()
        }
    }

    func stopScan() {
        centralManager?.stopScan()
        emitDeviceDiscovery(devices)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !devices.contains(peripheral) {
            devices.append(peripheral)
            emitDeviceDiscovery(devices)
        }
    }

    func connectToDevice(_ deviceId: String) {
        guard let peripheral = devices.first(where: { $0.identifier.uuidString == deviceId }) else {
            onErrorEventSink?("Device not found.")
            return
        }

        connectedPeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }

    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID!])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) {
                    peripheral.discoverCharacteristics([characteristicUUID!], for: service)
                    break
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUID {
                    peripheral.setNotifyValue(true, for: characteristic)
                    break
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let dataString = String(data: data, encoding: .utf8) ?? ""
            onDataReceivedEventSink?(dataString)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        onErrorEventSink?("Disconnected from the device.")
    }

    private func emitDeviceDiscovery(_ devices: [CBPeripheral]) {
        let deviceInfos = devices.map { (peripheral) -> [String: String] in
            var deviceInfo: [String: String] = [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
            ]
            if let serviceUUID = peripheral.services?.first?.uuid.uuidString,
               let characteristicUUID = peripheral.services?.first?.characteristics?.first?.uuid.uuidString {
                deviceInfo["serviceUUID"] = serviceUUID
                deviceInfo["characteristicUUID"] = characteristicUUID
            }
            return deviceInfo
        }
        devicesEventSink?(deviceInfos)
    }
}
