//
//  GestaltView.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI
import PartyUI
import UniformTypeIdentifiers

struct GestaltView: View {
    @EnvironmentObject private var mgr: ErosionManager
    @StateObject private var store = GestaltStore.shared
    @AppStorage("mgOverrideGates") private var mgOverrideGates = false
    @AppStorage("mgWriteAtomically") private var mgWriteAtomically = true
    @AppStorage("mgAutoRespring") private var mgAutoRespring = false
    @AppStorage("hasShownSheet") private var hasShownSheet = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var mgSubtype = 0
    @State private var mgOgSubtype = 0
    @State private var mgOgDeviceName = ""
    @State private var mgEnableDeviceName = false
    @AppStorage("mgDeviceName") private var mgDeviceName = ""
    @AppStorage("ogMachineName") var ogMachineName = ""
    @State private var mgProductType = ""
    
    @State private var showInfoSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Picker("Subtype", selection: $mgSubtype) {
                            Text("Original (\(mgOgSubtype))").tag(mgOgSubtype)
                            if isDynamIslandHD() && doubleSystemVersion() < 19.0 {
                                Text("Disable Dynamic Island").tag(2436)
                            }
                            Text("iPhone 14 Pro").tag(2436)
                            Text("iPhone 14 Pro Max").tag(2796)
                            Text("iPhone 15 Pro Max").tag(2976)
                            if doubleSystemVersion() >= 18.0 {
                                Text("iPhone 16 Pro").tag(2622)
                                Text("iPhone 16 Pro Max").tag(2868)
                            }
                            if doubleSystemVersion() >= 26.0 {
                                Text("iPhone Air").tag(2736)
                            }
                            if isHomeButtonHD() {
                                Text("iPhone X Gestures").tag(2436)
                            }
                        }
                        Spacer()
                        Button {
                            Alertinator.shared.alert(title: "Subtype Info", body: MGMsg.subtype)
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                    Toggle("Custom Device Name", isOn: $mgEnableDeviceName)
                    if mgEnableDeviceName {
                        TextField("Device Name", text: $mgDeviceName)
                    }
                } header: {
                    HeaderLabel(text: "Artwork", icon: "paintbrush.pointed")
                }
                
                if !isDynamIslandHD() || !isAODHD() || !isBootChimeHD() || !isChargeLimitHD() || mgOverrideGates {
                    Section {
                        if !isDynamIslandHD() || mgOverrideGates {
                            PlainToggle(text: "Enable Dynamic Island", minSupportedVersion: 19.0, isOn: store.mgKeyBinding([MGKey.island]))
                        }
                        if !isAODHD() || mgOverrideGates {
                            PlainToggle(text: "Enable AOD", minSupportedVersion: 18.0, isOn: store.mgKeyBinding([MGKey.AOD, MGKey.AOTime]))
                            if store.isEnabled([MGKey.AOD]) {
                                PlainToggle(text: "Enable AOD Vibrancy", minSupportedVersion: 18.0, isOn: store.mgKeyBinding([MGKey.AODVibrancy]))
                            }
                        }
                        if !isBootChimeHD() || mgOverrideGates {
                            PlainToggle(text: "Enable Charge Limit", minSupportedVersion: 17.0, isOn: store.mgKeyBinding([MGKey.chargeLim]))
                        }
                        if !isChargeLimitHD() || mgOverrideGates {
                            PlainToggle(text: "Enable Boot Chime", isOn: store.mgKeyBinding([MGKey.bootChime]))
                        }
                    } header: {
                        HeaderLabel(text: "Hardware Features", icon: "gearshape")
                    }
                }
                
                Section {
                    PlainToggle(text: "Enable Internal Install", infoType: .info, infoMessage: MGMsg.intInstall, isOn: store.mgKeyBinding([MGKey.intInstall]))
                    PlainToggle(text: "Enable Internal Build", infoType: .info, infoMessage: MGMsg.intBuild, isOn: store.mgKeyBinding([MGKey.intBuild]))
                } header: {
                    HeaderLabel(text: "Internal", icon: "ant")
                }
                .disabled(store.isEnabled([MGKey.appIntell]))
                
                Section {
                    PlainToggle(text: "Enable SRD UI", minSupportedVersion: 26.0, isOn: store.mgKeyBinding([MGKey.srd]))
                    PlainToggle(text: "Disable Region Restrictions", isOn: store.mgRegionRestrictionsBinding())
                    if !isAppleIntellHD() || mgOverrideGates {
                        PlainToggle(text: "Enable Apple Intelligence", minSupportedVersion: 18.1, isOn: store.mgKeyBinding([MGKey.appIntell]))
                            .onChange(of: store.mgKeyBinding([MGKey.appIntell]).wrappedValue) { (oldVal, newVal) in
                                if newVal {
                                    store.mgPullKeys([MGKey.intBuild, MGKey.intInstall])
                                }
                            }
                    }
                    HStack(spacing: 10) {
                        Picker("Spoofing", selection: $mgProductType) {
                            Text("Default").tag(ogMachineName)
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                if doubleSystemVersion() >= 17.4 {
                                    Text("iPad Pro 11-inch (M4)").tag("iPad16,3")
                                    Text("iPad Pro 11-inch (M4, Cellular)").tag("iPad16,4")
                                }
                                Text("iPad Pro 11-inch (4th Gen)").tag("iPad14,3")
                                Text("iPad Pro 11-inch (4th Gen, Cellular)").tag("iPad14,4")
                            } else {
                                Text("iPhone 15 Pro").tag("iPhone16,1")
                                Text("iPhone 15 Pro Max").tag("iPhone16,2")
                                if doubleSystemVersion() >= 18.0 {
                                    Text("iPhone 16").tag("iPhone17,3")
                                    Text("iPhone 16 Plus").tag("iPhone17,4")
                                    Text("iPhone 16 Pro").tag("iPhone17,1")
                                    Text("iPhone 16 Pro Max").tag("iPhone17,2")
                                }
                                if doubleSystemVersion() >= 19.0 {
                                    Text("iPhone 17").tag("iPhone18,3")
                                    Text("iPhone 17 Pro").tag("iPhone18,1")
                                    Text("iPhone 17 Pro Max").tag("iPhone18,2")
                                    Text("iPhone Air").tag("iPhone18,4")
                                }
                            }
                        }
                        Button {
                            Alertinator.shared.alert(title: "Device Spoofing Info", body: isAppleIntellHD() ? MGMsg.spoofUseless : MGMsg.spoofAI)
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    HeaderLabel(text: "Eligibility", icon: "flag")
                }
                
                Section {
                    if !isCrashDectHD() || mgOverrideGates {
                        PlainToggle(text: "Crash Detection", isOn: store.mgKeyBinding([MGKey.crashDet]))
                    }
                    if !isPWMHD() || mgOverrideGates {
                        PlainToggle(text: "Pulse Width Modulation", minSupportedVersion: 19.0, isOn: store.mgKeyBinding([MGKey.pwm]))
                    }
                    if ogMachineName.contains("iPhone") || mgOverrideGates {
                        PlainToggle(text: "Apple Pencil", isOn: store.mgKeyBinding([MGKey.appPencil]))
                    }
                    if !isCamControlHD() || mgOverrideGates {
                        PlainToggle(text: "Camera Control", minSupportedVersion: 18.0, isOn: store.mgKeyBinding([MGKey.camButton, MGKey.grapPefr]))
                    }
                    if !isActionButtonHD() || mgOverrideGates {
                        PlainToggle(text: "Action Button", minSupportedVersion: 17.0, isOn: store.mgKeyBinding([MGKey.actButton]))
                    }
                    if isHomeButtonHD() || mgOverrideGates {
                        PlainToggle(text: "Tap to Wake", isOn: store.mgKeyBinding([MGKey.tapToWake]))
                    }
                } header: {
                    HeaderLabel(text: "Preference Bundles", icon: "gear")
                }
                
                Section {
                    if machineName().contains("iPad") || mgOverrideGates {
                        PlainToggle(text: "Enable Stage Manager", isOn: store.mgKeyBinding([MGKey.stageMgr]))
                    }
                    if store.strVal(forKey: MGKey.deviceClass) == "iPhone" || mgOverrideGates {
                        PlainToggle(text: "Enable iPadOS UI", infoType: .warning, infoMessage: MGMsg.ipadOS, isOn: store.mgTrollPadBinding())
                    }
                } header: {
                    HeaderLabel(text: "iPadOS", icon: "ipad")
                }
            }
            .navigationTitle("MobileGestalt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            mgRevert()
                        } label: {
                            Label("Revert Tweaks", systemImage: "xmark")
                        }
                        
                        Button(role: .destructive) {
                            Alertinator.shared.alert(title: "Are you sure you'd like to reset MobileGestalt?", body: MGMsg.mgReset, actionLabel: "Confirm", action: {
                                do {
                                    try fm.removeItem(at: MGURL.savedGestaltURL)
                                    try fm.removeItem(at: MGURL.fsGestaltURL)
                                    Alertinator.shared.alert(title: "Successfully reset MobileGestalt!", body: MGMsg.mgResetComp, showCancel: false, actionLabel: "Exit App", action: { exitinator() })
                                } catch {
                                    print("(mg) failed to reset mobilegestalt: \(error)")
                                }
                            })
                        } label: {
                            Label("Reset Gestalt", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        NavigationLink {
                            List {
                                Section {
                                    Button("Export Current Gestalt") {
                                        presentShareSheet(with: MGURL.fsGestaltURL)
                                    }
                                    Button("Export Original Gestalt") {
                                        presentShareSheet(with: MGURL.savedGestaltURL)
                                    }
                                    Button("Reset Saved Gestalt", role: .destructive) {
                                        Alertinator.shared.alert(title: "Warning!", body: "Before you save MobileGestalt, remove all tweaks so that they don't get re-applied if you ever want to reset again.", action: {
                                            try? fm.removeItem(at: MGURL.savedGestaltURL)
                                            let _ = mgLoadData()
                                        })
                                    }
                                } header: {
                                    HeaderLabel(text: "Data", icon: "loupe")
                                }
                                
                                Section {
                                    PlainToggle(text: "Show Hidden Tweaks", infoType: .warning, infoMessage: "By showing tweaks that are intentionally hidden on your specific device configuration, you may be able to enable features that could break your device or lead to data loss!", isOn: $mgOverrideGates)
                                    Toggle("Respring after Apply", isOn: $mgAutoRespring)
                                    Toggle("Overwrite Atomically", isOn: $mgWriteAtomically)
                                } footer: {
                                    Text("If you choose to overwrite MobileGestalt atomically, it will not revert after a reboot.")
                                }
                            }
                            .navigationTitle("Gestalt Settings")
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply", role: .adaptiveConfirm) {
                        if !hasShownSheet {
                            showInfoSheet = true
                        } else {
                            dismiss()
                            hasShownSheet = true
                            mgApply()
                        }
                    }
                }
            }
            .sheet(isPresented: $showInfoSheet) {
                NavigationStack {
                    VStack {
                        InfoSheet(title: "Before you begin...") {
                            InfoSheetCell(title: "Important Warning!", icon: "exclamationmark.triangle.fill", context: MGMsg.support)
                                .modifier(SectionPlatter())
                            InfoSheetCell(title: "Apple Intelligence (Classic)", icon: "apple.intelligence", context: MGMsg.spoofAI)
                            InfoSheetCell(title: "iPadOS UI", icon: "ipad", context: MGMsg.ipadOS)
                            InfoSheetCell(title: "Region Restrictions", icon: "map", context: MGMsg.region)
                        } button: {
                            Button("Apply") {
                                mgApply()
                            }
                            .buttonStyle(ConfirmButtonStyle())
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Cancel") {
                                showInfoSheet = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.mgCurrentDict = mgLoadData()
                let isWritable = fm.isWritableFile(atPath: MGURL.fsGestaltURL.path)
                if !isWritable {
                    let res = BadQuery().grantAccess(atPath: MGURL.fsGestaltURL.deletingLastPathComponent().path, toFileName: "com.apple.MobileGestalt.plist")
                    if !res.0 {
                        Alertinator.shared.alert(title: "Failed to get write access to MobileGestalt!", body: "Tweaks will NOT apply. Maybe try restarting the app?")
                    }
                }
            }
        }
    }
    
    private func mgLoadData() -> NSMutableDictionary {
        do {
            let mgData = try Data(contentsOf: MGURL.fsGestaltURL)
            if !fm.fileExists(atPath: MGURL.savedGestaltURL.path) {
                try mgData.write(to: MGURL.savedGestaltURL)
            }
            
            if let ogDict = NSDictionary(contentsOf: MGURL.savedGestaltURL),
               let ogCacheExtra = ogDict["CacheExtra"] as? NSDictionary,
               let ogArtwork = ogCacheExtra[MGKey.artwork] as? NSDictionary {
                mgOgSubtype = ogArtwork["ArtworkDeviceSubType"] as? Int ?? 0
                mgOgDeviceName = ogArtwork["ArtworkDeviceProductDescription"] as? String ?? ""
            } else {
                throw "failed to get information from mobilegestalt"
            }
            
            guard let currentDict = NSMutableDictionary(contentsOf: MGURL.fsGestaltURL) else {
                throw "failed to get nsmutabledictionary from mobilegestalt"
            }
            
            if let cacheExtra = currentDict["CacheExtra"] as? NSDictionary,
               let artwork = cacheExtra[MGKey.artwork] as? NSDictionary {
                mgSubtype = artwork["ArtworkDeviceSubType"] as? Int ?? 0
                mgDeviceName = artwork["ArtworkDeviceProductDescription"] as? String ?? ""
                if mgDeviceName != mgOgDeviceName {
                    mgEnableDeviceName = true
                }
                mgProductType = cacheExtra[MGKey.prodType] as? String ?? machineName()
            }
            
            return currentDict
        } catch {
            print("[!] failed to get mobilegestalt: \(error)")
            Alertinator.shared.alert(title: "Failed to get MobileGestalt!", body: "Tweaks will not work properly. Please leave this page", showCancel: false, actionLabel: "Exit", action: { dismiss() })
        }
        
        return [:]
    }
    
    private func mgApply() {
        do {
            let mgDictToApply = store.mgCurrentDict
            
            if let cacheExtra = mgDictToApply["CacheExtra"] as? NSMutableDictionary,
               let artwork = cacheExtra[MGKey.artwork] as? NSMutableDictionary {
                artwork["ArtworkDeviceSubType"] = mgSubtype
                if mgEnableDeviceName {
                    artwork["ArtworkDeviceProductDescription"] = mgDeviceName
                }
                cacheExtra[MGKey.prodType] = mgProductType
            } else {
                throw "failed to write keys to mobilegestalt!"
            }
            
            let data = try PropertyListSerialization.data(fromPropertyList: mgDictToApply, format: .binary, options: 0)
            let res = mgWrite(data)
            
            if res {
                print("[*] successfully overwrote mobilegestalt!")
                Haptic.shared.play(.soft)
                if mgAutoRespring {
                    mgr.shouldRespring = true
                }
            } else {
                throw "overwrite failed!"
            }
        } catch {
            print("[!] failed to apply mobilegestalt: \(error)")
            Alertinator.shared.alert(title: "Failed to apply MobileGestalt!", body: "Error: \(error)")
        }
    }
    
    private func mgRevert() {
        do {
            guard let mgDictToApply = NSMutableDictionary(contentsOf: MGURL.savedGestaltURL) else {
                throw "failed to get mobilegestalt dict!"
            }
            
            let data = try PropertyListSerialization.data(fromPropertyList: mgDictToApply, format: .binary, options: 0)
            let res = mgWrite(data)
            
            if res {
                print("[*] successfully overwrote mobilegestalt!")
                Haptic.shared.play(.soft)
            } else {
                throw "overwrite failed!"
            }
        } catch {
            print("[!] failed to revert mobilegestalt: \(error)")
            Alertinator.shared.alert(title: "Failed to revert MobileGestalt!", body: "Error: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
