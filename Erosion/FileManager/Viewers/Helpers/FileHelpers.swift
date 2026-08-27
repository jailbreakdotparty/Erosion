//
//  FileHelpers.swift
//  Filos
//
//  Created by lunginspector on 7/22/26.
//

import SwiftUI
import PartyUI
import ZIPFoundation
import UniformTypeIdentifiers

extension FileManager {
    func createDirectoryIfNeeded(at url: URL) throws {
        if !self.fileExists(atPath: url.path) {
            try self.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}

func getFileDict(_ url: URL) -> [String : Any]? {
    if let data = try? Data(contentsOf: url),
       let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String : Any] {
        return dict
    }
    
    return nil
}

func getFileText(_ url: URL) -> String {
    do {
        let data = try Data(contentsOf: url)
        
        if let text = String(data: data, encoding: .utf8) {
            return text
        }
        
        return String(decoding: data, as: UTF8.self)
    } catch {
        print("(fm) failed to get text! path: \(error)")
        return ""
    }
}

func makeTemp(_ fileURL: URL) -> URL? {
    do {
        let neededAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if neededAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let tempURL = URL.temporaryDirectory.appendingPathComponent("\(fileURL.lastPathComponent)")
        if fm.fileExists(atPath: tempURL.path) {
            try fm.removeItem(at: tempURL)
        }
        try fm.copyItem(at: fileURL, to: tempURL)
        return tempURL
    } catch {
        print("[!] failed to make temp: \(error)")
    }
    return nil
}

func generateNavPath(path: String) -> String {
    if !path.contains("/") || path.isEmpty {
        return ""
    }
    
    let file = getFileItem(at: URL(fileURLWithPath: path))
    
    if file.type == .folder || file.type == .symlink {
        return path
    }
    
    if file.type == .file {
        let navPath = URL(fileURLWithPath: path).deletingLastPathComponent().path
        return navPath
    }
    return ""
}

func renameFile(_ url: URL, to newName: String) -> Bool {
    do {
        let data = try Data(contentsOf: url)
        try fm.removeItem(at: url)
        let targetURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        try data.write(to: targetURL)
        return true
    } catch {
        print("[!] failed to rename file: \(error)")
    }
    return false
}

func zipFile(_ url: URL) -> Bool {
    do {
        let zipDest = url
            .deletingLastPathComponent()
            .appendingPathComponent(url.lastPathComponent + ".zip")
        try FileManager.default.zipItem(at: url, to: zipDest, shouldKeepParent: true)
        return true
    } catch {
        print("[!] failed to zip file: \(error)")
    }
    return false
}

func unzipFile(_ url: URL) -> Bool {
    do {
        let unzipDest = url.deletingLastPathComponent()
        try fm.createDirectory(at: unzipDest, withIntermediateDirectories: true)
        try fm.unzipItem(at: url, to: unzipDest)
        return true
    } catch {
        print("[!] failed to uncompress file: \(error)")
    }
    return false
}

func duplicateFile(_ url: URL) -> Bool {
    do {
        let targetURL = {
            if url.pathExtension == "" {
                return url
                    .deletingLastPathComponent()
                    .appendingPathComponent("\(url.deletingPathExtension().lastPathComponent)_copy")
            }
            return url
                .deletingLastPathComponent()
                .appendingPathComponent("\(url.deletingPathExtension().lastPathComponent)_copy.\(url.pathExtension)")
        }()
        let data = try Data(contentsOf: url)
        try data.write(to: targetURL)
        return true
    } catch {
        print("[!] failed to duplicate file: \(error)")
    }
    return false
}

func copyFileToClipboard(_ url: URL) -> Bool {
    do {
        guard let tempURL = makeTemp(url) else {
            throw "failed to make temp!"
        }
        let data = try Data(contentsOf: tempURL)
        let utType = UTType(filenameExtension: tempURL.pathExtension) ?? .data
        
        UIPasteboard.general.setData(data, forPasteboardType: utType.identifier)
        return true
    } catch {
        print("[!] failed to copy file: \(error)")
    }
    return false
}

func conformsToPlistViewer(_ url: URL) -> Bool {
    do {
        guard let data = try? Data(contentsOf: url) else { return false }
        let _ = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String : Any]
        return true
    } catch {
        return false
    }
}

func conformsToTextViewer(_ url: URL) -> Bool {
    do {
        let _ = try String(contentsOf: url, encoding: .utf8)
        return true
    } catch {
        return false
    }
}
