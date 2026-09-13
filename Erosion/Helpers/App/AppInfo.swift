//
//  AppInfo.swift
//  Erosion
//
//  Created by lunginspector on 9/12/26.
//

import SwiftUI
import UIKit

enum AppInfo {
    public static var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"] as! String
    }
    public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }
    public static var appBuild: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    public static var appIcon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon) ?? UIImage()
        }
        return UIImage()
    }
}
