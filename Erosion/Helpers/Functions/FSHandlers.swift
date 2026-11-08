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
    func getDirPaths(_ path: String, maxInode: Int64 = 10000000) -> [String] {
        var array = [""]
        path.withCString { path in
            guard let res = bad_query_list(UnsafeMutablePointer(mutating: path), maxInode) else {
                return
            }
            defer { free(res) }
            
            let string = String(cString: res)
            array = string.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        }
        return array
    }
    
    // Skadz 2026-11-08: really broken. oohhh lunngg!! 
    func getContainerPath(at containerURL: URL = FSURL.appContainers, forMatch match: String, hashOnly: Bool = false) -> String {
        let handle = wq.grantAccess(path: containerURL.path)
        if !handle.0 {
            print("(fs) failed to get access to containers!")
            return ""
        }
        
        var collected: [String] = []
        do {
            let enumerated = try fm.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            
            for fileURL in enumerated {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
                if resourceValues.isDirectory == true {
                    collected.append(fileURL.path)
                }
            }
        } catch {
            print("Failed to load enumerate directories!")
        }
        
        for path in collected {
            guard let url = URL(string: path) else {
                continue
            }
            var buf = [CChar](repeating: 0, count: 512)
            let len = getxattr(path, "com.apple.containermanager.identifier", &buf, 511, 0, 0)
            if len > 0 {
                let bundleID = String(cString: buf)
                if bundleID == match {
                    if hashOnly {
                        return url.lastPathComponent
                    }
                    return url.path
                }
            }
        }
        
        worse_query_release(handle.1)
        
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
