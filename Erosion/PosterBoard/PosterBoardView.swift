//
//  PosterBoardView.swift
//  Erosion
//
//  Created by lunginspector on 8/19/26.
//

import SwiftUI
import PartyUI
import UniformTypeIdentifiers

let pbHandler = PBHandler()

struct PosterBoardView: View {
    @AppStorage("pbContainerPath") private var pbContainerPath = ""
    @AppStorage("tendiesArray") private var tendiesArray: [TendiesObject] = []
    @AppStorage("showTips") private var showTips = true
    
    @State private var showImporter = false
    @State private var isApplying = false
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            if tendiesArray.isEmpty {
                Button {
                    showImporter = true
                } label: {
                    VStack(alignment: .leading) {
                        CompactAlert(title: "No tendies imported!", icon: "exclamationmark.triangle.fill", text: "Import some tendies to start applying custom wallpapers.")
                            .padding(.horizontal, 15)
                    }
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach($tendiesArray) { $tendies in
                    Button {
                        if !tendies.isOn && tendiesArray.filter({ $0.isOn }).flatMap({ $0.descrNames }).count > 15 {
                            Alertinator.shared.alert(title: "Max wallpaper limit reached!", body: "You can only set a maximum of 15 wallpapers at a time. De-select another wallpaper pack if you'd like to apply this one!")
                        } else {
                            tendies.isOn.toggle()
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: tendies.targetDescr == .photos ? "play.rectangle" : "photo")
                                .imageScale(.large)
                                .foregroundStyle(Color.accentColor)
                            VStack {
                                Text(tendies.name)
                                    .lineLimit(1)
                                    .fontWeight(.medium)
                                Text("\(tendies.descrNames.count) wallpaper" + (tendies.descrNames.count == 1 ? "" : "s"))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .padding(.vertical, 10)
                        .background {
                            if tendies.targetDescr == .mercury {
                                VStack {
                                    Text("M")
                                        .font(.footnote)
                                        .padding(6)
                                        .background(Color.accentColor)
                                        .clipShape(.circle)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                                .padding(12)
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color(.secondarySystemBackground))
                                .overlay {
                                    if tendies.isOn {
                                        RoundedRectangle(cornerRadius: 26)
                                            .fill(Color.clear)
                                            .strokeBorder(lineWidth: 2)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                let url = AppURL.pbFolders.appendingPathComponent(tendies.folderName)
                                try? fm.removeItem(at: url)
                                tendiesArray.removeAll { $0.id == tendies.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
            .foregroundStyle(Color(.label))
        }
        .navigationTitle("PosterBoard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            doSetupStuff()
        }
        .overlay {
            if isApplying {
                if #available(iOS 26.0, *) {
                    HStack {
                        ProgressView()
                        Text("Applying Wallpapers...")
                    }
                    .padding(15)
                    .glassEffect(in: .rect(cornerRadius: 24))
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showImporter = true
                    } label: {
                        Label("Import .tendies", systemImage: "arrow.down.doc")
                    }
                    
                    Button {
                        LSApplicationWorkspace().openApplication(withBundleID: "com.apple.PosterBoard")
                    } label: {
                        Label("Open PosterBoard", systemImage: "arrow.up.right.square")
                    }
                    
                    Divider()
                    
                    NavigationLink {
                        List {
                            Section {
                                TextField("PosterBoard Path", text: $pbContainerPath, axis: .vertical)
                                Button("Open PosterBoard") {
                                    LSApplicationWorkspace().openApplication(withBundleID: "com.apple.PosterBoard")
                                }
                                Button("Reset Collections", role: .destructive) {
                                    let res = resetWallpapers(for: PBPath.wpKit)
                                    if res {
                                        Haptic.shared.play(.soft)
                                    }
                                }
                                Button("Reset MercuryPoster", role: .destructive) {
                                    let res = resetWallpapers(for: PBPath.mercury)
                                    if res {
                                        Haptic.shared.play(.soft)
                                    }
                                }
                                Button("Reset Videos", role: .destructive) {
                                    let res = resetWallpapers(for: PBPath.photos)
                                    if res {
                                        Haptic.shared.play(.soft)
                                    }
                                }
                            } header: {
                                HeaderLabel(text: "PosterBoard", icon: "photo")
                            }
                            
                            Section {
                                Button("Clear Imports", role: .destructive) {
                                    for object in tendiesArray {
                                        let url = AppURL.pbFolders.appendingPathComponent(object.folderName)
                                        try? fm.removeItem(at: url)
                                    }
                                    tendiesArray.removeAll()
                                }
                            } header: {
                                HeaderLabel(text: "Data", icon: "loupe")
                            }
                            
                            Section {
                                Toggle("Show Tips", isOn: $showTips)
                            } header: {
                                HeaderLabel(text: "View Options", icon: "eyes.inverse")
                            }
                        }
                        .navigationTitle("PosterBoard Settings")
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Apply", role: .adaptiveConfirm) {
                    var res = false
                    if tendiesArray.filter({ $0.isOn }).flatMap({ $0.descrNames }).count > 5 && showTips {
                        Alertinator.shared.alert(title: "Before you begin...", body: "You have more than five wallpapers set. This may cause wallpapers to take a long time to apply, depending on how large they are. Are you still sure that you'd like to apply these wallpapers?", actionLabel: "Confirm", action: {
                            isApplying = true
                            res = applyObjects(tendiesArray.filter { $0.isOn }, at: AppURL.symlinks)
                        })
                    } else {
                        isApplying = true
                        res = applyObjects(tendiesArray.filter { $0.isOn }, at: AppURL.symlinks)
                    }
                    isApplying = false
                    if !res {
                        Alertinator.shared.alert(title: "Failed to apply wallpapers!", body: "Please ensure that none of your wallpapers are corrupted, and try again.")
                    } else {
                        Haptic.shared.play(.soft)
                        if showTips {
                            Alertinator.shared.alert(title: "Restart PosterBoard to finish applying!", body: "PosterBoard will open once you continue. Please kill it from the App Switcher", showCancel: false, actionLabel: "Continue", action: { LSApplicationWorkspace().openApplication(withBundleID: "com.apple.PosterBoard") })
                        } else {
                            LSApplicationWorkspace().openApplication(withBundleID: "com.apple.PosterBoard")
                        }
                    }
                }
                .disabled(tendiesArray.filter({ $0.isOn }).isEmpty)
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
            handleImport(result)
        }
    }
    
    private func doSetupStuff() {
        if pbContainerPath.isEmpty {
            pbContainerPath = FSHandlers().getPBContainer()
        }
        if !fm.fileExists(atPath: AppURL.pb.path) {
            try? fm.createDirIfNeeded(at: AppURL.pb)
            try? fm.createDirIfNeeded(at: AppURL.pbFolders)
        }
    }
    
    private func applyObjects(_ objects: [TendiesObject], at url: URL) -> Bool {
        let descrTargets = Set(objects.map(\.targetDescr))
        for descrTarget in descrTargets {
            let target = "\(pbContainerPath)/\(descrTarget.path)"
            let res = bq.grantAccess(atPath: target)
            if !res.0 {
                print("(mg) failed to grant access at \(target): \(res.2)")
                return false
            }
        }
        
        for object in objects {
            let container = "\(pbContainerPath)/\(object.targetDescr.path)"
            for descr in object.descrNames {
                let target = URL(fileURLWithPath: container).appendingPathComponent(UUID().uuidString)
                let descrURL = AppURL.pbFolders.appendingPathComponent(object.folderName).appendingPathComponent(descr)
                do {
                    try fm.copyItem(at: descrURL, to: target)
                } catch {
                    print("(mg) failed to copy item at \(descrURL) to \(target): \(error)")
                    return false
                }
            }
        }
        return true
    }
    
    private func resetWallpapers(for item: PBPath) -> Bool {
        do {
            let target = URL(fileURLWithPath: "\(pbContainerPath)/\(item.path)")
            let contents = try fm.contentsOfDirectory(at: target, includingPropertiesForKeys: nil)
            
            for url in contents {
                try fm.removeItem(at: url)
            }
            return true
        } catch {
            print("(pb) failed to reset \(item.rawValue): \(error)")
            return false
        }
    }
    
    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let fileURL):
            let stopAccess = fileURL.startAccessingSecurityScopedResource()
            defer {
                if stopAccess {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }
            if let tendies = pbHandler.makeObjectFromTendies(at: fileURL) {
                tendiesArray.append(tendies)
            }
        case .failure(let error):
            print("(pb) failed to import file: \(error)")
        }
    }
}

