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
    func getDirPaths(_ path: String, maxInode: Int64 = 100000) -> [String] {
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
    
    func getContainerPath(at containerURL: URL = FSURL.appContainers, forMatch match: String, hashOnly: Bool = false) -> String {
        let containers = getDirPaths(containerURL.path)
        for path in containers {
            let url = URL(fileURLWithPath: path)
            if let appName = folderLabel(url: url) {
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
