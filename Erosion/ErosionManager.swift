//
//  ErosionManager.swift
//  Erosion
//
//  Created by lunginspector on 8/24/26.
//

import Combine
import SwiftUI

let build = "Build 1"

enum Errors {
    static var checkLogs = "Check error logs for more detailed information."
}

enum AppURL {
    static let pb = URL.documentsDirectory.appendingPathComponent("PosterBoard")
    static let pbFolders = AppURL.pb.appendingPathComponent("Wallpapers")
    static let ps = URL.documentsDirectory.appendingPathComponent("Passcode Themes")
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
    @Published var refreshFiles = false
    
    @Published var storedFiles = [FileItem]()
    @Published var storedURL: URL = URL(fileURLWithPath: "/")
    
    @AppStorage("pbContainerHash") var pbContainerHash = ""
    @AppStorage("mpContainerHash") var mpContainerHash = ""
    private var leakedPaths = [String]()
    @Published var isFetching = false
    
    init() {}
    
    func getHashesRamp(increment: Int = 2400000, maxAttempts: Int = 4) -> Bool {
        var currentInode = 100000
        for _ in 0..<maxAttempts {
            print("(fs) trying to get container hashes with inode \(currentInode)...")
            let res = fetchContainerHashes(withInode: currentInode)
            if res {
                isFetching = false
                return true
            } else {
                print("(fs) failed to get hashes! retrying with higher inode...")
                currentInode += increment
            }
        }
        return false
    }
    
    func fetchContainerHashes(withInode maxInode: Int) -> Bool {
        var mpDidUpdate = false
        var pbDidUpdate = false
        leakedPaths = fsHandlers.getDirPaths(FSPaths.appContainers, maxInode: maxInode)
        if let mpNewHash = fsHandlers.getContainerPath(leakedPaths, forMatch: "com.apple.mobilephone", hashOnly: true) {
            mpContainerHash = mpNewHash
            mpDidUpdate = true
        }
        if let pbNewHash = fsHandlers.getContainerPath(leakedPaths, forMatch: "com.apple.PosterBoard", hashOnly: true) {
            pbContainerHash = pbNewHash
            pbDidUpdate = true
        }
        return mpDidUpdate && pbDidUpdate
    }
}
