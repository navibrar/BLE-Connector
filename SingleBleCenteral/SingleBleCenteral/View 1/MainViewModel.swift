//
//  MainViewModel.swift
//  SingleBleCenteral
//
//  Created by Navpreet Kaur on 2/12/2022.
//

import SwiftUI
import CoreBluetooth
import Combine

final class MainViewModel: ObservableObject {

    @Published var state: CBManagerState = .unknown {
        didSet {
            update(with: state)
        }
    }
    @AppStorage("identifier") private var identifier: String = ""
    @Published var peripheral: CBPeripheral?

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    //MARK: - Lifecycle

    func start() {
        manager.stateSubject.sink { [weak self] state in
            self?.state = state
        }
        .store(in: &cancellables)
        manager.start()
    }

    //MARK: - Private

    private func update(with state: CBManagerState) {
        guard peripheral == nil else {
            return
        }
        guard state == .poweredOn else {
            return
        }
        manager.peripheralSubject
            .filter { $0.identifier == UUID(uuidString: self.identifier)}
            .sink { [weak self] in
                if $0.state == .disconnected {
                    self?.peripheral = nil
                } else {
                    self?.peripheral = $0
                }
            }
            .store(in: &cancellables)
        manager.scan()
    }
}
