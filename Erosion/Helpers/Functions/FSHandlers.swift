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
    func getDirPaths(_ path: String) -> [String] {
        // skidded from worse_query. thx forcequit 1000x!!
        let baselineURL = fm.temporaryDirectory.appendingPathComponent(".baseline_\(UUID().uuidString)")
        var baselineInode: UInt64 = 0
        var paths: [String] = []
        
        do {
            try "thxforcequit".write(to: baselineURL, atomically: true, encoding: .utf8)
            var baselineInfo = stat()
            let baselinePath = baselineURL.path
            
            if stat(baselinePath, &baselineInfo) == 0 {
                baselineInode = baselineInfo.st_ino
                print("(fs) baseline: \(baselineInode)")
            } else {
                print("(fs) Failed to get baseline inode!")
            }
            
            try fm.removeItem(at: baselineURL)
        } catch {
            print("(fs) Failed to get baseline inode: \(error)")
            return []
        }
        
        print("(fs) pathleaking \(path)")
        let leakedPaths = pathleak(path, baselineInode) ?? []
        print("(fs) got \(leakedPaths.count) paths via pathleak")
        paths = leakedPaths
        
        if paths.count == 0 {
            print("(fs) got no paths! something went wrong.")
        }
        
        return paths
    }
    
    func getContainerPath(at containerURL: URL = FSURL.appContainers, forMatch match: String, hashOnly: Bool = false) -> String {
        let containers = getDirPaths(containerURL.path)
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
        print("(fs) failed to get container for \(match)! containers: \(containerURL.path)")
        return ""
    }
    
    func openInFilesApp(_ fileURL: URL) {
        guard var components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false) else { return }
        components.scheme = "shareddocuments"
        guard let filesAppURL = components.url else { return }
        UIApplication.shared.open(filesAppURL)
    }
}
