//
//  DevicesListView.swift
//  SingleBleCenteral
//
//  Created by Navpreet Kaur on 2/12/2022.
//

import SwiftUI
import CoreBluetooth

struct DevicesListView: View {

    @StateObject private var viewModel: DevicesListViewModel = .init()
    @Binding var peripheral: CBPeripheral?
    @Environment(\.presentationMode) private var presentationMode

    private var peripherals: [CBPeripheral] {
        viewModel.peripherals.sorted { left, right in
            guard let leftName = left.name else {
                return false
            }
            guard let rightName = right.name else {
                return true
            }
            return leftName < rightName
        }
    }

    //MARK: - Lifecycle

    var body: some View {
        NavigationView {
            content.navigationTitle("Devices")
        }
        .onAppear {
            viewModel.start()
        }
    }

    //MARK: - Private

    @ViewBuilder
    private var content: some View {
        if viewModel.state == .poweredOn {
            List(peripherals, id: \.identifier) { peripheral in
                HStack {
                    if let peripheralName = peripheral.name {
                        Text(peripheralName)
                    } else {
                        Text("Unknown")
                            .opacity(0.2)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.peripheral = peripheral
                    viewModel.identifier = peripheral.identifier.uuidString
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            Text("Please enable bluetooth to search devices")
        }
    }
}

struct DevicesListView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesListView(peripheral: .constant(nil))
    }
}
