//
//  FilosHelpers.swift
//  Filos
//
//  Created by lunginspector on 7/22/26.
//

import SwiftUI

enum FolderType {
    case normal, bundle, container
}

func getFolderType(url: URL) -> FolderType {
    let parent = url.deletingLastPathComponent().path
    
    if parent == FSPaths.appBundles {
        return .bundle
    } else if parent == FSPaths.appContainers {
        return .container
    }
    return .normal
}

// skidded from worse_query. thx forcequit 1000x!!
func getBIDFromXattr(_ url: URL) -> String? {
    let handle = wq.grantAccess(path: url.path).1
    
    if handle > 0 {
        var buf = [CChar](repeating: 0, count: 512)
        let len = getxattr(url.path, "com.apple.containermanager.identifier", &buf, 511, 0, 0)
        
        if len < 0 {
            // errno 93: attribute not found
            if errno != 93 {
                print("failed to read xattr: \(String(cString: strerror(errno))) (errno \(errno))")
            }
            return nil
        }
        
        let bid = String(cString: buf)
        
        wq.releaseHandle(handle)
        
        if !bid.isEmpty {
            return bid
        }
    }
    return nil
}

enum SysBID {
    static var phone = "com.apple.mobilephone"
    static var poster = "com.apple.PosterBoard"
}
