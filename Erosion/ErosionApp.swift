//
//  ErosionApp.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI
import PartyUI
import Combine
import UniformTypeIdentifiers

let device = UIDevice.current
let fm = FileManager.default
var weOnADebugBuild = false
var pipe = Pipe()
var sema = DispatchSemaphore(value: 0)
let build = "Release"

enum AppURL {
    static let pb = URL.documentsDirectory.appendingPathComponent("PosterBoard")
    static let symlinks = AppURL.pb.appendingPathComponent("Symlinks")
    static let pbFolders = AppURL.pb.appendingPathComponent("Wallpapers")
}

final class ErosionManager: ObservableObject {
    static let shared = ErosionManager()
    @Published var logOutput = ""
    @Published var shouldRespring = false
    
    init() {}
}

enum AppTabs {
    case home, tweaks, wallpapers
}

@main
struct ErosionApp: App {
    @StateObject private var mgr = ErosionManager.shared
    @State private var currentTab = AppTabs.home
    
    init() {
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        // fix file picker
        let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.fix_init(forOpeningContentTypes:asCopy:)))!
        let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:)))!
        method_exchangeImplementations(origMethod, fixMethod)
        
        #if DEBUG
        weOnADebugBuild = true
        #else
        weOnADebugBuild = false
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mgr)
                .onAppear {
                    pipe.fileHandleForReading.readabilityHandler = { fh in
                        let data = fh.availableData
                        
                        if data.isEmpty {
                            fh.readabilityHandler = nil
                            sema.signal()
                            return
                        }
                        
                        guard let text = String(data: data, encoding: .utf8) else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            mgr.logOutput.append(text)
                        }
                    }
                    print("")
                    print("[*] Erosion v0.1 (\(build))")
                    print("[*] Running on \(UIDevice.current.systemName) \(UIDevice.current.systemVersion), \(machineName())")
                    if !isSupported() && !weOnADebugBuild {
                        Alertinator.shared.alert(title: "Your \(device.systemName) version is not supported!", body: "We're sorry, but the exploits that Erosion rely on are patched in this version.", showCancel: false, actionLabel: "Exit", action: { exitinator() })
                    }
                }
                .overlay {
                    if mgr.shouldRespring {
                        RespringView()
                            .brightness(-1.0)
                            .ignoresSafeArea()
                    }
                }
        }
    }
}

extension UIDocumentPickerViewController {
    @objc func fix_init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) -> UIDocumentPickerViewController {
        return fix_init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}
