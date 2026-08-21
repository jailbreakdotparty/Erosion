//
//  mg.swift
//  mond
//
//  Created by ruter on 16.07.26.
//

import Foundation
import Darwin
import MachO
import UIKit
import PartyUI

func mgWrite(_ data: Data) -> Bool {
    var res: (Bool, String)
    if UserDefaults.standard.bool(forKey: "mgWriteAtomically") {
        res = writeFileAtomically(data, to: MGURL.fsGestaltURL)
    } else {
        res = writeFileTemp(data, to: MGURL.fsGestaltURL)
    }
    
    if !res.0 {
        print("(mg) failed to apply gestalt: \(res.1)")
        return false
    }
    return true
}

// device info getters
// HD - hardware device
func isDynamIslandHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone17,5"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isAODHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone15,2", "iPhone15,3", "iPhone16,1", "iPhone16,2", "iPhone17,1", "iPhone17,2", "iPhone18,1", "iPhone18,2", "iPhone18,3", "iPhone18,4"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isChargeLimitHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone17,5", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone18,4", "iPhone18,5", "iPad16,1", "iPad16,2", "iPad15,7", "iPad15,8", "iPad14,8", "iPad14,9", "iPad14,10", "iPad14,11", "iPad15,3", "iPad15,4", "iPad15,5", "iPad15,6", "iPad16,8", "iPad16,9", "iPad16,10", "iPad16,11", "iPad16,3", "iPad16,4", "iPad16,5", "iPad16,6", "iPad17,1", "iPad17,2", "iPad17,3", "iPad17,4"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isBootChimeHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone14,7", "iPhone14,8", "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone17,5", "iPhone18,1", "iPhone18,2", "iPhone18,3", "iPhone18,4", "iPhone18,5"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isHomeButtonHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices: [String] = ["iPhone12,8", "iPhone14,6"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

// fun...
func isAppleIntellHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone17,5", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone18,4", "iPhone18,5", "iPad16,1", "iPad16,2", "iPad13,16", "iPad13,17", "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7", "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11", "iPad14,3", "iPad14,4", "iPad14,5", "iPad14,6", "iPad14,8", "iPad14,9", "iPad14,10", "iPad14,11", "iPad15,3", "iPad15,4", "iPad15,5", "iPad15,6", "iPad16,3", "iPad16,4", "iPad16,5", "iPad16,6", "iPad16,8", "iPad16,9", "iPad16,10", "iPad16,11", "iPad17,1", "iPad17,2", "iPad17,3", "iPad17,4"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isCrashDectHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone14,7", "iPhone14,8", "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone17,5", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone18,4", "iPhone18,5"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isPWMHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone18,4"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isCamControlHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone18,4"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

func isActionButtonHD() -> Bool {
    if let machineName = UserDefaults.standard.string(forKey: "ogMachineName") {
        let hdDevices = ["iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone17,5", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone18,4", "iPhone18,5"]
        if hdDevices.contains(machineName) {
            return true
        }
    }
    return false
}

