//
//  GestaltStore.swift
//  Erosion
//
//  Created by lunginspector on 8/19/26.
//

import SwiftUI
import PartyUI
import Combine

let currentGestaltURL = URL(fileURLWithPath: "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
let ogGestaltSavedURL = URL.documentsDirectory.appendingPathComponent("OriginalGestalt.plist")

final class GestaltStore: ObservableObject {
    static let shared = GestaltStore()
    
    @Published var mgCurrentDict = NSMutableDictionary()
    
    init() {}
    
    // MARK: bindings
    func mgKeyBinding(_ keys: [String], defaultValue: Int = 0, enableValue: Int = 1) -> Binding<Bool> {
        guard let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        
        return Binding(get: {
            if let value = cacheExtra[keys.first!] as? Int {
                return value == enableValue
            }
            return false
        }, set: { enabled in
            self.objectWillChange.send()
            for key in keys {
                // if it exists inside of the plist, then update it. if not then pull the value completely.
                if enabled {
                    cacheExtra[key] = enableValue
                } else {
                    cacheExtra.removeObject(forKey: key)
                }
            }
        })
    }
    
    func mgPullKeys(_ keys: [String]) {
        guard let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary else {
            return
        }
        
        for key in keys {
            cacheExtra.removeObject(forKey: key)
        }
    }
    
    func mgTrollPadBinding() -> Binding<Bool> {
        guard let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        let keys = [
            "uKc7FPnEO++lVhHWHFlGbQ", // ipad
            "mG0AnH/Vy1veoqoLRAIgTA", // MedusaFloatingLiveAppCapability
            "UCG5MkVahJxG1YULbbd5Bg", // MedusaOverlayAppCapability
            "ZYqko/XM5zD3XBfN5RmaXA", // MedusaPinnedAppCapability
            "nVh/gwNpy7Jv1NOk00CMrw", // MedusaPIPCapability,
            "qeaj75wk3HF4DwQ8qbIi7g", // DeviceSupportsEnhancedMultitasking
        ]
        
        return Binding(get: {
            if let value = cacheExtra[keys.first!] as? Int? {
                return value == 1
            }
            return false
        }, set: { enabled in
            self.objectWillChange.send()
            if enabled {
                Alertinator.shared.alert(title: "Warning!", body: mgInfoMessages.ipadOSWarning)
            }
            
            if self.mgSetiPadOS(enable: enabled) {
                for key in keys {
                    if enabled {
                        cacheExtra[key] = 1
                    } else {
                        cacheExtra.removeObject(forKey: key)
                    }
                }
            }
        })
    }
    
    func mgRegionRestrictionsBinding() -> Binding<Bool> {
        guard let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        
        return Binding<Bool>(
            get: {
                return cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] as? String == "LL" &&
                cacheExtra["yK+xavymRGZ3xWc1tb8XDg"] as? String == "LL/A"
            },
            set: { enabled in
                self.objectWillChange.send()
                if enabled {
                    Alertinator.shared.alert(title: "Warning!", body: "This tweak may break regional laws! In this case, you may be held responsible for any consequences given by your local jurisdiction. Use this tweak at your own risk!")
                    cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] = "LL"
                    cacheExtra["yK+xavymRGZ3xWc1tb8XDg"] = "LL/A"
                } else {
                    cacheExtra.removeObject(forKey: "h63QSdBCiT/z0WU6rdQv6Q")
                    cacheExtra.removeObject(forKey: "yK+xavymRGZ3xWc1tb8XDg")
                }
            }
        )
    }
    
    // vibecoded.party
    func mgSetiPadOS(enable: Bool) -> Bool {
        guard let cacheData = mgCurrentDict["CacheData"] as? Data else {
            print("(mg) failed to set ipados: couldn't get cachedata")
            return false
        }
        let hexString = cacheData.map { String(format: "%02x", $0) }.joined()
        var hex = Array(hexString)
        let sliceStart = 1616
        let sliceLength = 200
        
        guard hex.count > sliceStart else {
            print("(mg) failed to set ipados: cache data is too short to contain the required slice.")
            return false
        }
        
        let end = min(hex.count, sliceStart + sliceLength)
        let slice = String(hex[sliceStart..<end])
        
        guard let regex = try? NSRegularExpression(pattern: "0+(?:5555)*([0-9a-f]{4})") else { return false }
        let nsRange = NSRange(slice.startIndex..<slice.endIndex, in: slice)
        
        var matchedOffset: Int?
        regex.enumerateMatches(in: slice, range: nsRange) { match, _, stop in
            guard let match = match,
                  let range = Range(match.range(at: 1), in: slice) else { return }
            
            let value = slice[range]
            if value.filter({ $0 != "0" }).count >= 3 {
                matchedOffset = sliceStart + slice.distance(from: slice.startIndex, to: range.lowerBound)
                stop.pointee = true
            }
        }
        
        guard let offset = matchedOffset else {
            print("(mg) failed to set ipados: target pattern not found within the specified slice.")
            return false
        }
        
        let rightOffset = offset + 13
        let leftOffset = offset - 67
        
        guard leftOffset > 0, rightOffset < hex.count - 1 else {
            print("(mg) failed to set ipados: calculated offsets are out of bounds.")
            return false
        }
        
        for position in [leftOffset, rightOffset] {
            guard ["1", "3"].contains(String(hex[position])),
                  hex[position - 1] == "0", hex[position + 1] == "0" else {
                print("(mg) failed to set ipados: validation failed at calculated offsets.")
                return false
            }
        }
        
        hex[leftOffset] = enable ? "3" : "1"
        
        let updatedHex = String(hex)
        var updatedData = Data(capacity: updatedHex.count / 2)
        
        var index = updatedHex.startIndex
        while index < updatedHex.endIndex {
            let next = updatedHex.index(index, offsetBy: 2)
            guard next <= updatedHex.endIndex,
                  let byte = UInt8(updatedHex[index..<next], radix: 16) else {
                print("(mg) failed to set ipados: failed to reconstruct data from hex string.")
                return false
            }
            updatedData.append(byte)
            index = next
        }
        
        mgCurrentDict["CacheData"] = updatedData
        return true
    }
}
