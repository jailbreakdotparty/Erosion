//
//  DeviceInfoHelpers.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import Foundation
import PartyUI

// version support for different functions
func mgSupported() -> Bool {
    let buildNum = buildNumber()
    if doubleSystemVersion() == 27.0 && (buildNum == "24A5355q" || buildNum == "24A5370h" || buildNum == "24A5380h" || buildNum == "24A5390f") {
        return true
    }
    return false
}

// device info getters
func machineName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
}

func buildNumber() -> String {
    var versString = [CChar](repeating: 0, count: 16)
    var versStringLen = size_t(versString.count - 1)
    let res = sysctlbyname("kern.osversion", &versString, &versStringLen, nil, 0)
    if res == 0, let buildNum = String(validatingUTF8: versString) {
        return buildNum
    }
    return "Unknown"
}
