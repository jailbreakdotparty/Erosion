//
//  FSHandlers.swift
//  Erosion
//
//  Created by lunginspector on 8/19/26.
//

import Foundation
import UIKit

let fsHandlers = FSHandlers()

class FSHandlers {
    func getDirPaths(_ path: String, maxInode: Int?) -> [String] { // put maxInode to nil to use baseline method (longer), otherwise uses specified, fallbacks to 7500000
        // skidded from worse_query. thx forcequit 1000x!!
        var plMaxInode: UInt64 = UInt64(maxInode ?? 7500000) // use inode passed to function, fallback to 7500000
        var paths: [String] = []
        
        if maxInode == nil {
            do {
                let baselineURL = fm.temporaryDirectory.appendingPathComponent(".baseline_\(UUID().uuidString)")
                try "thxforcequit".write(to: baselineURL, atomically: true, encoding: .utf8)
                var baselineInfo = stat()
                let baselinePath = baselineURL.path
                
                if stat(baselinePath, &baselineInfo) == 0 {
                    plMaxInode = baselineInfo.st_ino
                    print("(fs) baseline: \(plMaxInode)")
                } else {
                    print("(fs) Failed to get baseline inode!")
                }
                
                try fm.removeItem(at: baselineURL)
            } catch {
                print("(fs) Failed to get baseline inode: \(error)")
                return []
            }
        }
        
        print("(fs) pathleaking \(path), max \(plMaxInode)")
        let leakedPaths = pathleak(path, plMaxInode) ?? []
        print("(fs) got \(leakedPaths.count) paths via pathleak")
        paths = leakedPaths
        
        if paths.count == 0 {
            print("(fs) got no paths! something went wrong.")
        }
        
        return paths
    }
    
    func getContainerPath(at containerURL: URL = FSURL.appContainers, forMatch match: String, hashOnly: Bool = false) -> String {
        let containers = getDirPaths(containerURL.path, maxInode: 10000)
        for path in containers {
            let url = URL(fileURLWithPath: path)
            if let appName = getBIDFromXattr(url) {
                if appName == match {
                    if hashOnly {
                        return url.lastPathComponent
                    }
                    return url.path
                }
            }
        }
        print("(fs) failed to get container for \(match)!")
        return ""
    }
    
    func openInFilesApp(_ fileURL: URL) {
        guard var components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false) else { return }
        components.scheme = "shareddocuments"
        guard let filesAppURL = components.url else { return }
        UIApplication.shared.open(filesAppURL)
    }
}
