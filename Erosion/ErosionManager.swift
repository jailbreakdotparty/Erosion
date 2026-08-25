//
//  ErosionManager.swift
//  Erosion
//
//  Created by lunginspector on 8/24/26.
//

import Foundation
import Combine

let build = "Release"

enum AppURL {
    static let pb = URL.documentsDirectory.appendingPathComponent("PosterBoard")
    static let pbFolders = AppURL.pb.appendingPathComponent("Wallpapers")
}

enum AppMsg {
    static let opFailed = "Restart the app and try again. If this issue persists, your device may be unsupported, or this specific tweak may not work on your device properly."
    static let applied = "Respring your device for changes to take effect."
    static let unsupported = "We're sorry, but the exploits that Erosion rely on are patched in this version. Please exit the app."
}

final class ErosionManager: ObservableObject {
    static let shared = ErosionManager()
    @Published var logOutput = ""
    @Published var shouldRespring = false
    
    init() {}
}
