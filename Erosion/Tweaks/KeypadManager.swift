//
//  KeypadManager.swift
//  Erosion
//
//  Created by lunginspector on 8/27/26.
//

import Combine
import Foundation
import UIKit
import ZIPFoundation

/*
 TelephonyUI-10:
 -
 */

// i hate you, apple incorporated.
// with love, lunginspector. august 28th, 2026.
enum KeypadID: String, CaseIterable {
    case one, two, three, four, five, six, seven, eight, nine, star, zero, pound
    
    var fileNames: [String] {
        switch self {
        case .one: return getFileNames(forKey: "en-1-")
        case .two: return getFileNames(forKey: "en-2-A B C")
        case .three: return getFileNames(forKey: "en-3-D E F")
        case .four: return getFileNames(forKey: "en-4-G H I")
        case .five: return getFileNames(forKey: "en-5-J K L")
        case .six: return getFileNames(forKey: "en-6-M N O")
        case .seven: return getFileNames(forKey: "en-7-P Q R S")
        case .eight: return getFileNames(forKey: "en-8-T U V")
        case .nine: return getFileNames(forKey: "en-9-W X Y Z")
        case .star: return getFileNames(forKey: "en-*-")
        case .zero: return getFileNames(forKey: "en-0-+")
        case .pound: return getFileNames(forKey: "en-#-")
        }
    }
    
    private func getFileNames(forKey key: String) -> [String] {
        let files = ["--mask.png", "--white.png", "-hi-mask.png", "-hi-white.png"]
        return files.map { key + $0 }
    }
    
    func getAccentedFileName() -> String {
        let appearance = UIScreen.main.traitCollection.userInterfaceStyle
        switch appearance {
        case .light: return self.fileNames[0]
        case .dark: return self.fileNames[1]
        default: return self.fileNames[0]
        }
    }
}

enum KPSize: Int, CaseIterable {
    case defSize, small, big, custom
    
    var float: CGFloat {
        switch self {
        case .small: return CGFloat(150)
        case .big: return CGFloat(225)
        default: return CGFloat(0)
        }
    }
    
    var label: String {
        switch self {
        case .defSize: return "Default"
        case .small: return "Small"
        case .big: return "Big"
        case .custom: return "Custom"
        }
    }
}

enum KPSizeLimits {
    static let min = CGFloat(50)
    static let max = CGFloat(2500)
}

struct KeypadItem: Identifiable, Equatable {
    let id = UUID()
    var kpID: KeypadID
    var imgData = Data()
    var ogImgData = Data()
}

let emptyKeypadArray = [
    KeypadItem(kpID: KeypadID.one), KeypadItem(kpID: KeypadID.two), KeypadItem(kpID: KeypadID.three), KeypadItem(kpID: KeypadID.four), KeypadItem(kpID: KeypadID.five), KeypadItem(kpID: KeypadID.six), KeypadItem(kpID: KeypadID.seven), KeypadItem(kpID: KeypadID.eight), KeypadItem(kpID: KeypadID.nine), KeypadItem(kpID: KeypadID.star), KeypadItem(kpID: KeypadID.zero), KeypadItem(kpID: KeypadID.pound)
]

enum KPMsg {
    static let resetWarn = "You'll lose both what you're currently editing and what you've already set inside of the Phone app."
    static let applyComp = "For changes to take effect, open the Phone app and change the appearance until your custom keys show up. You can also restart your device. Do NOT force kill the Phone app!"
}

let kp = KeypadManager()
final class KeypadManager: ObservableObject {
    static let shared = KeypadManager()
    
    @Published var mpKeypad = [KeypadItem]()
    
    private var mpContainerPath = {
        return UserDefaults.standard.value(forKey: "mpContainerPath") as? String ?? ""
    }
    
    init() {
        if mpKeypad.isEmpty {
            mpKeypad = emptyKeypadArray
        }
    }
    
    func updateKeypadItem(forID id: KeypadID, withData data: Data, ogData: Data? = nil) {
        if let index = mpKeypad.firstIndex(where: { $0.kpID == id }) {
            mpKeypad[index].imgData = data
            if let data = ogData {
                mpKeypad[index].ogImgData = data
            }
        }
    }
    
    func applyKeypadItems() {
        for item in mpKeypad {
            let files = item.kpID.fileNames
            for fileName in files {
                let finalURL = URL(fileURLWithPath: mpContainerPath()).appendingPathComponent("Library/Caches/TelephonyUI-10").appendingPathComponent(fileName)
                do {
                    try item.imgData.write(to: finalURL)
                } catch {
                    print("[!] failed to write image data: \(error)")
                }
            }
        }
    }
    
    func resetKeypadItems() -> Bool {
        do {
            let filesURL = URL(fileURLWithPath: mpContainerPath()).appendingPathComponent("Library/Caches/TelephonyUI-10")
            let files = try fm.contentsOfDirectory(at: filesURL, includingPropertiesForKeys: [])
            for fileURL in files {
                try fm.removeItem(at: fileURL)
            }
            return true
        } catch {
            print("[!] failed to reset keypad items: \(error)")
        }
        return false
    }
    
    func resizeAndRet(withData data: Data, newSize: CGFloat = CGFloat(0), customSize: CGSize? = nil, isDefault: Bool = false) -> Data {
        if let image = UIImage(data: data) {
            var width = isDefault ? image.size.width : customSize?.width ?? newSize
            var height = isDefault ? image.size.height: customSize?.height ?? newSize
            width = min(max(width, KPSizeLimits.min), KPSizeLimits.max)
            height = min(max(height, KPSizeLimits.min), KPSizeLimits.max)
            let resized = image.resized(to: CGSize(width: width, height: height))
            if let newData = resized.pngData() {
                return newData
            }
        }
        return data
    }
    
    func getCurrentKeypads(size: KPSize = KPSize.defSize, custW: Int = 0, custH: Int = 0, isOnAppear: Bool = false) {
        do {
            let filesURL = URL(fileURLWithPath: mpContainerPath()).appendingPathComponent("Library/Caches/TelephonyUI-10")
            for kpId in KeypadID.allCases {
                let fileName = kpId.getAccentedFileName()
                let url = filesURL.appendingPathComponent(fileName)
                let data = try Data(contentsOf: url)
                let imgData = {
                    switch size {
                    case .defSize: return resizeAndRet(withData: data, isDefault: true)
                    case .custom: return resizeAndRet(withData: data, customSize: CGSize(width: custW, height: custH))
                    default: return resizeAndRet(withData: data, newSize: size.float)
                    }
                }()
                if isOnAppear {
                    updateKeypadItem(forID: kpId, withData: imgData, ogData: imgData)
                } else {
                    updateKeypadItem(forID: kpId, withData: imgData)
                }
            }
        } catch {
            // keypads could've been reset so nothing to log here, logs are just gonna spit out nonsense
        }
    }
    
    func changeSizeOfKeypads(size: KPSize = KPSize.defSize, custW: Int = 0, custH: Int = 0) {
        for kpItem in mpKeypad {
            let data = kpItem.ogImgData
            let imgData = {
                switch size {
                case .defSize: return resizeAndRet(withData: data, isDefault: true)
                case .custom: return resizeAndRet(withData: data, customSize: CGSize(width: custW, height: custH))
                default: return resizeAndRet(withData: data, newSize: size.float)
                }
            }()
            updateKeypadItem(forID: kpItem.kpID, withData: imgData)
        }
    }
    
    func importTheme(fromURL fileURL: URL) -> Bool {
        do {
            let filesURL = URL.temporaryDirectory.appendingPathComponent(fileURL.deletingPathExtension().lastPathComponent + "_\(UUID())_EROSIONTMP")
            try fm.createDirectory(at: filesURL, withIntermediateDirectories: true)
            try fm.unzipItem(at: fileURL, to: filesURL)
            let fileURLs = try fm.contentsOfDirectory(at: filesURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                
            }
        } catch {
            print("[!] failed to import theme: \(error)")
        }
        return false
    }
}

extension UIImage {
    func resized(to size: CGSize, scale: CGFloat = 1.0) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
