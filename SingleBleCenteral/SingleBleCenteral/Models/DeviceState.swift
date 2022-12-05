//
//  Created by Artem Novichkov on 31.05.2021.
//

import Foundation
import CoreGraphics

final class DeviceState: ObservableObject {
    @Published var manufacturerName = "--"
    @Published var modelNumber = "--"
    @Published var serialNumber = "--"
    @Published var hardwareRevision = "--"
    @Published var firmwareRevision = "--"
    @Published var softwareRevision = "--"
    @Published var systemID = "--"
}
