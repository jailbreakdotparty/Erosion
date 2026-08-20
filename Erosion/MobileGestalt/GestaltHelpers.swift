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

enum mgInfoMessages {
    static var ipadOSWarning = "This tweak is incredibly risky to use! Do not use this tweak if you have an alphanumeric passcode. Also, do turn off \"Show Dock In Stage Manager\", as your device will BOOTLOOP when rotating to landscape. Furthermore, this tweak will cause genernal instability in apps and weird scaling issues."
    static var internalinstall = "This will enable a bunch of random features that are meant for Apple Internal use but were left inside of production iOS. Please note that enabling this toggle will break your ability to properly download Apple Intelligence or system apps from the App Store. Furthermore, this could cause other unforeseen issues with device functionality."
    static var spoofUseless = "Spoofing your device model may break Face ID as well as other features. This tweak won't be of any value to you."
    static var spoofAI = "Spoofing your device model may break Face ID as well as other features. You should only use it if you would like to download Apple Intelligence models on an unsupported device. Unspoofing could cause Apple Intelligence to break, but if you choose to unspoof, do NOT go back into the Apple Intelligence & Siri settings at all!"
    static var aiInfo = "You will NOT get the new Siri AI features when enabling this tweak. For most device configurations, you'll only get the older Apple Intelligence UI. Make sure that you spoofed your device before applying."
    static var supportWarning = "DO NOT ASK US FOR SUPPORT IF SOMETHING DOES NOT WORK PROPERLY! Many of these tweaks are completely dependent on both your device and Apple's servers working properly."
}

func mgWrite(_ data: Data) -> Bool {
    var res: (Bool, String)
    if UserDefaults.standard.bool(forKey: "mgWriteAtomically") {
        res = writeFileAtomically(data, to: currentGestaltURL)
    } else {
        res = writeFileTemp(data, to: currentGestaltURL)
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

