//
//  DeviceViewModel.swift
//  SingleBleCenteral
//
//  Created by Navpreet Kaur on 2/12/2022.
//

import CoreBluetooth
import Combine

final class DeviceViewModel: ObservableObject {

    @Published var isReady = false
    @Published var deviceState: DeviceState = .init()

    private enum Constants {
        static let readServiceUUID: CBUUID = .init(string: "00001523-74B9-C1E2-1535-785FEABCD8AF")
        static let deviceIndormationUUID: CBUUID = .init(string: "180A")
//        static let peripheralUUID: CBUUID = .init(string: "CF4B8002-8F4D-711F-E805-5E8D27986779")
        static let serviceUUIDs: [CBUUID] = [readServiceUUID, deviceIndormationUUID]
        static let readCharacteristicUUID: CBUUID = .init(string: "00001526-74B9-C1E2-1535-785FEABCD8AF")
        static let writeCharacteristicUUID: CBUUID = .init(string: "00001533-74B9-C1E2-1535-785FEABCD8AF")
    }

    private enum DeviceConstants {
        static let manufacturerNameUUID = "2A29"
        static let modelNumberUUID = "2A24"
        static let serialNumberUUID = "2A25"
        static let hardwareRevisionUUID = "2A27"
        static let firmwareRevisionUUID = "2A26"
        static let softwareRevisionUUID = "2A28"
        static let syatemIdUUID = "2A23"
    }

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    private var peripheral: CBPeripheral
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?
    private var writeCharacteristicWithResponse: CBCharacteristic?

    //MARK: - Lifecycle

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

//    deinit {
//        cancellables.cancel()
//    }

    func connect() {
        manager.servicesSubject
//            .map { $0.filter { Constants.serviceUUIDs.contains($0.uuid) } }
            .sink { [weak self] services in
                services.forEach { service in
                    self?.peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            .store(in: &cancellables)

        manager.characteristicsSubject
            .filter { $0.0.uuid == Constants.deviceIndormationUUID }
            .compactMap { $0.1 }
            .sink { [weak self] characteristics in
                characteristics.forEach { characteristic in
                    self?.readCharacteristic = characteristic
                    if characteristic.properties.rawValue == 0x2 {
                        self?.peripheral.readValue(for: characteristic)
                    }
                    if characteristic.properties.rawValue == 0x10 {
                        self?.peripheral.setNotifyValue(true, for: characteristic)
                    }
                    if characteristic.properties.rawValue == 0x12 {
                        self?.peripheral.readValue(for: characteristic)
                        self?.peripheral.setNotifyValue(true, for: characteristic)
                    }
                    if characteristic.properties.rawValue == 0x1A {
                        self?.writeCharacteristic = characteristic
                    }
                    if characteristic.properties.rawValue == 0x1E {
                        self?.writeCharacteristicWithResponse = characteristic
                    }
                    if characteristic.uuid == Constants.writeCharacteristicUUID {
                        self?.writeCharacteristicWithResponse = characteristic
                    }
                }
            }
            .store(in: &cancellables)

        manager.characteristicsValue
            .sink {
                [weak self] characteristic in
                print("READ characteristic == \(characteristic)")
                self?.deviceState(uuid: characteristic.uuid.uuidString, from: characteristic.value)
                self?.isReady = true
            }
            .store(in: &cancellables)

        manager.connect(peripheral)
    }

    func disconnect() {
        manager.disconnect(peripheral)
    }

    func write(_ data: String) {
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)

        guard let characteristic = writeCharacteristic else {
            return
        }
        peripheral.writeValue(valueString!, for: characteristic, type: .withoutResponse)
    }

    func writeWithResponse(_ data: String) {
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)

        guard let characteristic = writeCharacteristicWithResponse else {
            return
        }
        peripheral.writeValue(valueString!, for: characteristic, type: .withResponse)
    }

    private func deviceState(uuid:String, from data: Data?) {
        guard let data = data else {
            print("Error in data")
            return
        }
        let valueDescription = String(data: data, encoding: .utf8) ?? "--"
        print("uuid == \(uuid) and values == \(valueDescription)")

        if uuid == DeviceConstants.serialNumberUUID {
            self.deviceState.serialNumber = valueDescription
        } else if uuid == DeviceConstants.manufacturerNameUUID {
            self.deviceState.manufacturerName = valueDescription
        } else if uuid == DeviceConstants.modelNumberUUID {
            self.deviceState.modelNumber = valueDescription
        } else if uuid == DeviceConstants.hardwareRevisionUUID {
            self.deviceState.hardwareRevision = valueDescription
        } else if uuid == DeviceConstants.firmwareRevisionUUID {
            self.deviceState.firmwareRevision = valueDescription
        } else if uuid == DeviceConstants.softwareRevisionUUID {
            self.deviceState.softwareRevision = valueDescription
        } else if uuid == DeviceConstants.syatemIdUUID {
            self.deviceState.systemID = valueDescription
        }
    }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value?) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}
