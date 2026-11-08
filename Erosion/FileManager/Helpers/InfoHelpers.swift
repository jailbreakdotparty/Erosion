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

// this is awful
func getBIDFromXattr(_ url: URL) -> String? {
    wq.grantAccess(path: url.path)
    
    var buf = [UInt8](repeating: 0, count: 512)
    
    let len = buf.withUnsafeMutableBytes {
        getxattr(url.path, "com.apple.containermanager.identifier", $0.baseAddress, 511, 0, XATTR_NOFOLLOW)
    }
    if len < 0 {
        print("failed to read xattr: \(String(cString: strerror(errno))) (errno \(errno))")
        return nil
    }
    let bid = String(cString: buf)
    
    if !bid.isEmpty {
        return bid
    }
    return nil
}

// i don't know why root's works and mine doesn't, but i'm stealing it.
func folderLabel(url: URL) -> String? {
    /*
    let candidates = [
        url.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist"),
        url.appendingPathComponent("com.apple.mobile_container_manager.metadata.plist")
    ]

    for url in candidates {
        if let data = try? Data(contentsOf: url), let id = metadataID(from: data) {
            return id
        }
    }

    for url in candidates {
        if let id = readMetaKey(at: url, key: "MCMMetadataIdentifier") {
            return id
        }
    }
     */

    return getBIDFromXattr(url)
}

func metadataID(from data: Data) -> String? {
    let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
    return plist?["MCMMetadataIdentifier"] as? String
}

func readMetaKey(at url: URL, key: String) -> String? {
    if url.path.contains("/var/mobile/Containers/Shared/AppGroup") && ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 26 {
        let handle = worse_query(url.path, group, true, false)
        guard handle >= 0 else { return nil }
        do { worse_query_release(handle) }
    } else {
        let handle = worse_query(url.path, group, false, false)
        guard handle >= 0 else { return nil }
        do { worse_query_release(handle) }
    }
     
    guard let data = try? Data(contentsOf: url),
          let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
        return nil
    }

    return plist[key] as? String
}

enum SysBID {
    static var phone = "com.apple.mobilephone"
    static var poster = "com.apple.PosterBoard"
}
