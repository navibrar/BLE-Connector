//
//  BluetoothManager.swift
//  SingleBleCenteral
//
//  Created by Navpreet Kaur on 2/12/2022.
//

import Combine
import CoreBluetooth

final class BluetoothManager: NSObject {

    static let shared: BluetoothManager = .init()

    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    var servicesSubject: PassthroughSubject<[CBService], Never> = .init()
    var characteristicsSubject: PassthroughSubject<(CBService, [CBCharacteristic]), Never> = .init()
    var characteristicsValue: PassthroughSubject<(CBCharacteristic), Never> = .init()

    private var centralManager: CBCentralManager!

    //MARK: - Lifecycle

    func start() {
        centralManager = .init(delegate: self, queue: .main)
    }

    func scan() {
        centralManager.scanForPeripherals(withServices: nil)
    }

    func connect(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    func disconnect(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Error in disconnecting from peripheral : \(error)")
            // Handle error
            return
        }
        print("Disconnected from peripheral")
        peripheralSubject.send(peripheral)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        servicesSubject.send(services)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }

        //        Read: 0x02
        //        Write [without response]: 0x04
        //        Write [with response]: 0x08
        //        Notify: 0x10

        //        0x1A = 0x10 | 0x08 | 0x02 is Notify, Write [with response] and Read
        //        0x1E = 0x10  | 0x08 | 0x04| 0x02 is Notify, Write [without response], Write [with response], and Read
        //        0x12 = 0x10 | 0x02 is Notify, Read only

        characteristicsSubject.send((service, characteristics))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            print("ERROR didUpdateValueFor characteristic == \(error)")
        } else {
            print("characteristic == \(characteristic)")
        }
        characteristicsValue.send(characteristic)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.isNotifying {
            print("Subscribed to \(characteristic.uuid)");
        } else {
            print(error?.localizedDescription ?? "n/a");
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        peripheral.readRSSI();
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("The following message has been sent: \(characteristic.value.map { String(format: "%02x", $0.description )} ?? "--")");
    }
}
