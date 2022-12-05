//
//  DeviceView.swift
//  SingleBleCenteral
//
//  Created by Navpreet Kaur on 2/12/2022.
//

import SwiftUI
import CoreBluetooth

struct DeviceView: View {

    @StateObject private var viewModel: DeviceViewModel
    @State private var didAppear = false

    //MARK: - Lifecycle

    init(peripheral: CBPeripheral) {
        let viewModel = DeviceViewModel(peripheral: peripheral)
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        content()
            .onAppear {
                guard didAppear == false else {
                    return
                }
                didAppear = true
                viewModel.connect()
            }
    }

    //MARK: - Private
    @ViewBuilder
    private func content() -> some View {
        if viewModel.isReady {
            VStack {
                deviceInfoView(name: "manufacturerName", value: viewModel.deviceState.manufacturerName)
                deviceInfoView(name: "modelNumber", value: viewModel.deviceState.modelNumber)
                deviceInfoView(name: "serialNumber", value: viewModel.deviceState.serialNumber)
                deviceInfoView(name: "hardwareRevision", value: viewModel.deviceState.hardwareRevision)
                deviceInfoView(name: "firmwareRevision", value: viewModel.deviceState.firmwareRevision)
                deviceInfoView(name: "softwareRevision", value: viewModel.deviceState.softwareRevision)
                deviceInfoView(name: "systemID", value: viewModel.deviceState.systemID)

                Button(action: {
                    viewModel.disconnect()
                }) {
                    MainButton(text: "Disconnect")
                }

                Button(action: {
                    viewModel.write("Hello World")
                }) {
                    MainButton(text: "Write With Response")
                }

                Button(action: {
                    viewModel.write("Hello World")
                }) {
                    MainButton(text: "Write Without Responce")
                }

            }.padding()
        }
        else {
            Text("Connecting...")
        }
    }

    struct deviceInfoView: View {
        var name: String
        var value: String

        var body: some View {
            HStack {
                Text(name)
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .font(.title3)

                Spacer()

                Text(value)
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .font(.title3)
            }
        }
    }
}

//struct DeviceView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceView()
//    }
//}
