//
//  FileItemHelpers.swift
//  Filos
//
//  Created by lunginspector on 8/1/26.
//

import Foundation
import UniformTypeIdentifiers

struct FileItem: Identifiable {
    let id = UUID()
    var name: String
    var fileURL: URL
    var destURL: URL
    var type: FileType
    var uttype: UTType
    var size: Int
    var creationDate: Date
    var modifiedDate: Date
    var creationDateStr: String
    var modifiedDateStr: String
    
    var hidden: Bool
    var posixPerms: String
    var owner: String
    var group: String
    var readable: Bool
    var writable: Bool
    var executable: Bool
}

let clearFileItem = FileItem(name: "", fileURL: URL(fileURLWithPath: ""), destURL: URL(fileURLWithPath: ""), type: .file, uttype: .data, size: 0, creationDate: Date(), modifiedDate: Date(), creationDateStr: "", modifiedDateStr: "", hidden: false, posixPerms: "", owner: "", group: "", readable: false, writable: false, executable: false)

func getFileItem(at url: URL, isContainer: Bool = false) -> FileItem {
    var item = FileItem(name: url.lastPathComponent, fileURL: url, destURL: url, type: .file, uttype: .data, size: 0, creationDate: Date(), modifiedDate: Date(), creationDateStr: "", modifiedDateStr: "", hidden: false, posixPerms: "", owner: "", group: "", readable: false, writable: false, executable: false)
    
    if isContainer {
        if let folderName = folderLabel(url: url) {
            item.name = folderName
        }
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy h:mm a"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    let keys: Set<URLResourceKey> = [.isSymbolicLinkKey, .isDirectoryKey, .contentTypeKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey, .isHiddenKey]
    if let values = try? url.resourceValues(forKeys: keys) {
        if values.isSymbolicLink ?? false {
            if let path = try? fm.destinationOfSymbolicLink(atPath: url.path) {
                item.destURL = URL(fileURLWithPath: path)
            }
        }
        if let symlink = values.isSymbolicLink, let directory = values.isDirectory {
            item.type = symlink ? .symlink : directory ? .folder : .file
        }
        item.uttype = values.contentType ?? .data
        item.size = values.fileSize ?? 0
        if let date = values.creationDate {
            item.creationDate = date
            item.creationDateStr = formatter.string(from: date)
        } else {
            item.creationDateStr = ""
        }
        if let date = values.contentModificationDate {
            item.modifiedDate = date
            item.modifiedDateStr = formatter.string(from: date)
        } else {
            item.modifiedDateStr = ""
        }
        item.hidden = values.isHidden ?? false
    }
    if let attrs = try? fm.attributesOfItem(atPath: url.path) {
        if let perms = attrs[.posixPermissions] as? NSNumber {
            item.posixPerms = String(format: "%04o", perms.intValue)
        }
        if let owner = attrs[.ownerAccountName] as? String {
            item.owner = owner
        }
        if let group = attrs[.groupOwnerAccountName] as? String {
            item.group = group
        }
    }
    item.readable = fm.isReadableFile(atPath: url.path)
    item.writable = fm.isWritableFile(atPath: url.path)
    item.executable = fm.isExecutableFile(atPath: url.path)
    
    return item
}

enum FileType: String {
    case file, folder, symlink
    
    var sortOrder: Int {
        switch self {
        case .file: return 0
        case .symlink: return 1
        case .folder: return 2
        }
    }
}

private func getContainerFiles(at url: URL) -> [FileItem] {
    var files: [FileItem] = []
    let paths = fsHandlers.getDirPaths(url.path)
    for path in paths {
        files.append(getFileItem(at: URL(fileURLWithPath: path)))
    }
    return files
}
