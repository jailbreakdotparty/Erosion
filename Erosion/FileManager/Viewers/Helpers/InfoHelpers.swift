//
//  FilosHelpers.swift
//  Filos
//
//  Created by lunginspector on 7/22/26.
//

import SwiftUI
import PartyUI

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

// i don't know why root's works and mine doesn't, but i'm stealing it.
func folderLabel(url: URL) -> String? {
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

    return nil
}

func metadataID(from data: Data) -> String? {
    let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
    return plist?["MCMMetadataIdentifier"] as? String
}

func readMetaKey(at url: URL, key: String) -> String? {
    var path_c = url.path.utf8CString.map { Int8($0) }
    let handle = bad_query(&path_c, true, nil, false, nil)
    guard handle >= 0 else { return nil }
    defer { bad_query_release(handle) }
     
    guard let data = try? Data(contentsOf: url),
          let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
        return nil
    }

    return plist[key] as? String
}
