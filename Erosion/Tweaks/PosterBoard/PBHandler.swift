//
//  PosterBoardHandler.swift
//  Erosion
//
//  Created by lunginspector on 8/19/26.
//

import Foundation
import ZIPFoundation

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
            try fm.unzipItem(at: url, to: rawURL)
            
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
                    let descrName = "CustomDescriptor_\(tendiesName)_\(UUID())"
                    let targetURL = descrRootURL.appendingPathComponent(descrName)
                    try fm.moveItem(at: url, to: targetURL)
                    tendiesObject.descrNames.append(descrName)
                    randomizeWPIds(targetURL)
                }
                print("(pb) imported new .tendies successfully!\nObject: \(tendiesObject)")
                return tendiesObject
            }
        } catch {
            print("(pb) failed to extract .tendies: \(error)")
        }
        return nil
    }
    
    private func randomizeWPIds(_ descrURL: URL) {
        let id = Int.random(in: 9999...99999)
        var descrFiles: [URL] = []
        if let enumerator = fm.enumerator(at: descrURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                let fileAtts = try? fileURL.resourceValues(forKeys: [.isRegularFileKey])
                if fileAtts?.isRegularFile ?? false {
                    descrFiles.append(fileURL)
                }
            }
        }
        
        for url in descrFiles {
            switch url.lastPathComponent {
            case "com.apple.posterkit.provider.descriptor.identifier":
                try? String(id).data(using: .utf8)?.write(to: url)
            case "com.apple.posterkit.provider.contents.userInfo":
                setPlistValAndWrite(url, key: "wallpaperRepresentingIdentifier", value: id)
            case "Wallpaper.plist":
                setPlistValAndWrite(url, key: "identifier", value: id)
            default: continue
            }
        }
    }
    
    private func setPlistValAndWrite(_ url: URL, key: String, value: Any) {
        do {
            guard let data = fm.contents(atPath: url.path),
                  var dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String : Any] else {
                throw "failed to get plist!"
            }
            dict[key] = value
            guard let newData = try? PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0) else {
                throw "failed to serialize dict!"
            }
            try newData.write(to: url)
        } catch {
            print("(pb) failed to update plist: \(error)")
        }
    }
}
