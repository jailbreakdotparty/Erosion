//
//  PosterBoardHandler.swift
//  Erosion
//
//  Created by lunginspector on 8/19/26.
//

import Foundation
import CoreFoundation

struct TendiesObject: Identifiable, Codable {
    var id = UUID()
    var name: String
    var folderName: String
    var descrNames: [String]
    var isOn: Bool = false
    var targetDescr: PBPath = .wpKit
}

enum PBPath: String, Codable, CaseIterable {
    case wpKit, mercury, photos
    
    var path: String {
        switch self {
        case .wpKit: return "Library/Application Support/PRBPosterExtensionDataStore/61/Extensions/com.apple.WallpaperKit.CollectionsPoster/descriptors"
        case .mercury: return "Library/Application Support/PRBPosterExtensionDataStore/61/Extensions/com.apple.MercuryPoster/descriptors"
        case .photos: return "Library/Application Support/PRBPosterExtensionDataStore/61/Extensions/com.apple.PhotosUIPrivate.PhotosPosterProvider/descriptors"
        }
    }
}

final class PBHandler {
    func makeObjectFromTendies(at url: URL) -> TendiesObject? {
        let rawURL = URL.temporaryDirectory.appendingPathComponent("ImportedTendies_\(url.lastPathComponent)_\(UUID())")
        do {
            try Compression.shared.extract(path: url, to: rawURL)
            
            // before anything else, we need to get the urls at which the descriptors are stored. the only problem: importing this SUCKS SO MUCH BECAUSE NO ONE MADE A SPECIFIC FORMAT THAT .tendies SHOULD BE STRUCTRED IN!!!
            // this won't be fun.
            var rootURLs = try fm.contentsOfDirectory(at: rawURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            var pbPath = PBPath.wpKit
            
            func getDescriptorURLs() -> [URL]? {
                var descrURLs: [URL] = []
                
                // before anything else, we'll check to see if the files are perhaps nested. sometimes this happens.
                if let urlToReadRootFrom = rootURLs.first(where: { !$0.lastPathComponent.localizedCaseInsensitiveContains("descriptor") && !$0.lastPathComponent.localizedCaseInsensitiveContains("ordered-descriptor") && !$0.lastPathComponent.localizedCaseInsensitiveContains("container") && !$0.lastPathComponent.localizedCaseInsensitiveContains("__MACOSX") }) {
                    if let newURLs = try? fm.contentsOfDirectory(at: urlToReadRootFrom, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                        rootURLs = newURLs
                    }
                }
                
                // check #1: if the folder is any of these thingies and just add the urls it needs. super simple!
                for dirURL in rootURLs {
                    let dirName = dirURL.lastPathComponent
                    if dirName.localizedCaseInsensitiveContains("descriptor") || dirName.localizedCaseInsensitiveContains("ordered-descriptor") || dirName.localizedCaseInsensitiveContains("video-descriptor") {
                        if dirName.localizedCaseInsensitiveContains("video-descriptor") {
                            pbPath = .photos
                        }
                        if let folderURLs = try? fm.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                            if let _ = folderURLs.first(where: { $0.lastPathComponent == "VideoCAML" }) {
                                pbPath = .photos
                            }
                            for descrURL in folderURLs {
                                descrURLs.append(descrURL)
                            }
                            return descrURLs
                        }
                    }
                }
                
                // check #2: alright, so it might be nested inside of the container directory. see if it is and jump to it if so. this check also will tell us where we should write to.
                if let dirURL = rootURLs.first(where: { $0.lastPathComponent.localizedCaseInsensitiveContains("container") }) {
                    let options: [PBPath] = [.wpKit, .mercury, .photos]
                    
                    if let matched = options
                        .map({ (path: $0, url: dirURL.appendingPathComponent($0.path)) })
                        .first(where: { fm.fileExists(atPath: $0.url.path) }) {
                        pbPath = matched.path
                        if let folderURLs = try? fm.contentsOfDirectory(at: matched.url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                            for descrDir in folderURLs {
                                descrURLs.append(descrDir)
                            }
                            return descrURLs
                        }
                    }
                }
                return nil
            }
            
            if let descrURLs = getDescriptorURLs() {
                let tendiesName = url.deletingPathExtension().lastPathComponent
                var tendiesObject = TendiesObject(name: tendiesName, folderName: "", descrNames: [], targetDescr: pbPath)
                tendiesObject.folderName = "ImportedTendies_\(tendiesName)_\(UUID())"
                let descrRootURL = AppURL.pbFolders.appendingPathComponent(tendiesObject.folderName)
                try fm.createDirIfNeeded(at: descrRootURL)
                for url in descrURLs {
                    let descrName = tendiesObject.targetDescr == .mercury ? url.lastPathComponent : UUID().uuidString
                    let targetURL = descrRootURL.appendingPathComponent(descrName)
                    try fm.moveItem(at: url, to: targetURL)
                    tendiesObject.descrNames.append(descrName)
                    if tendiesObject.targetDescr == .photos {
                        try randomizeWPIds(targetURL, for: .photos)
                    }
                }
                print("(pb) imported new .tendies successfully!\nObject: \(tendiesObject)")
                return tendiesObject
            }
        } catch {
            print("(pb) failed to extract .tendies: \(error.localizedDescription)")
        }
        return nil
    }
    
    func copyDescriptor(at source: URL, to target: URL, for path: PBPath) throws {
        guard path == .wpKit,
              try source.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            try fm.copyItem(at: source, to: target)
            return
        }

        // Normalize a disposable copy so older imports are repaired without
        // changing the staged descriptor if normalization fails.
        let prepared = fm.temporaryDirectory.appendingPathComponent("PosterBoardDescriptor_\(UUID())")
        defer { try? fm.removeItem(at: prepared) }
        try fm.copyItem(at: source, to: prepared)
        // Older imports prefixed the descriptor folder's UUID with a name.
        let galleryID = UUID(uuidString: String(source.lastPathComponent.suffix(36))) ?? UUID()
        try randomizeWPIds(prepared, for: path, galleryID: galleryID)
        try fm.copyItem(at: prepared, to: target)
    }

    private func randomizeWPIds(_ descrURL: URL, for path: PBPath, galleryID: UUID? = nil) throws {
        let id: Int
        if let galleryID {
            // A staged descriptor already has a random UUID. Reusing it keeps
            // repeated Apply operations from giving the same import new identities.
            let randomPrefix = withUnsafeBytes(of: galleryID.uuid) { bytes in
                bytes.prefix(4).reduce(0) { ($0 << 8) | Int($1) }
            }
            id = 10000 + randomPrefix % 90000
        } else {
            id = Int.random(in: 9999...99999)
        }
        guard let enumerator = fm.enumerator(
            at: descrURL, includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            if path == .wpKit { throw "failed to enumerate wallpaper descriptor" }
            return
        }

        for case let url as URL in enumerator {
            guard (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { continue }
            do {
                switch url.lastPathComponent {
                case "com.apple.posterkit.provider.descriptor.identifier":
                    try String(id).write(to: url, atomically: true, encoding: .utf8)
                case "com.apple.posterkit.provider.contents.userInfo":
                    try updatePlist(at: url) {
                        $0["wallpaperRepresentingIdentifier"] = path == .wpKit ? String(id) as Any : id
                    }
                case "Wallpaper.plist":
                    try updatePlist(at: url) { wallpaper in
                        wallpaper["identifier"] = id
                        if path == .wpKit, var assets = wallpaper["assets"] as? [String: [String: [String: Any]]] {
                            for (kind, variants) in assets {
                                for (variant, asset) in variants where asset["identifier"] != nil {
                                    assets[kind]?[variant]?["identifier"] = id
                                }
                            }
                            wallpaper["assets"] = assets
                        }
                    }
                case "com.apple.posterkit.provider.identifierURL.suggestionMetadata.plist":
                    if let galleryID {
                        try updatePlist(at: url) { try updateSuggestionMetadata(&$0, id: id, galleryID: galleryID) }
                    }
                default:
                    continue
                }
            } catch {
                if path == .wpKit { throw error }
                print("(pb) failed to update plist: \(error.localizedDescription)")
            }
        }
    }

    private func updatePlist(at url: URL, edit: (inout [String: Any]) throws -> Void) throws {
        let data = try Data(contentsOf: url)
        guard var dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            throw "failed to get plist"
        }
        try edit(&dict)
        let newData = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        try newData.write(to: url, options: .atomic)
    }

    private func updateSuggestionMetadata(_ archive: inout [String: Any], id: Int, galleryID: UUID) throws {
        guard archive["$archiver"] as? String == "NSKeyedArchiver",
              var objects = archive["$objects"] as? [Any],
              let top = archive["$top"] as? [String: Any] else {
            throw "invalid wallpaper suggestion archive"
        }

        let rootIndex = try archiveIndex(top[NSKeyedArchiveRootObjectKey], in: objects)
        guard let root = objects[rootIndex] as? [String: Any] else {
            throw "invalid wallpaper suggestion root"
        }
        guard let itemReference = root["suggestedGalleryItem"] else { return }
        let itemIndex = try archiveIndex(itemReference, in: objects)
        guard itemIndex != 0 else { return } // An archived nil gallery item.
        guard let item = objects[itemIndex] as? [String: Any] else {
            throw "invalid wallpaper gallery item"
        }

        let descriptorIndex = try archiveIndex(item["descriptorIdentifier"], in: objects)
        let galleryIndex = try archiveIndex(item["identifier"], in: objects)
        guard descriptorIndex != galleryIndex,
              let identifier = objects[descriptorIndex] as? String,
              objects[galleryIndex] is String else {
            throw "invalid wallpaper gallery identifiers"
        }

        // The suffix (for example .DYNAMIC) is part of the provider's lookup key.
        let suffix = identifier.firstIndex(of: ".") ?? identifier.endIndex
        guard Int(identifier[..<suffix]) != nil else { return }
        objects[descriptorIndex] = String(id) + identifier[suffix...]
        objects[galleryIndex] = galleryID.uuidString
        archive["$objects"] = objects
    }

    private func archiveIndex(_ reference: Any?, in objects: [Any]) throws -> Int {
        guard let reference else { throw "missing wallpaper suggestion reference" }
        let uid = reference as CFTypeRef
        guard CFGetTypeID(uid) == _CFKeyedArchiverUIDGetTypeID() else {
            throw "invalid wallpaper suggestion reference"
        }
        let index = Int(_CFKeyedArchiverUIDGetValue(uid))
        guard objects.indices.contains(index) else { throw "invalid wallpaper suggestion index" }
        return index
    }
}
