//
//  GestaltView.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI
import PartyUI
import UniformTypeIdentifiers

struct CustomKey: Identifiable, Codable {
    var id: String { key }
    var label: String
    var key: String
    var value: String
    var isOn = false
}

struct GestaltView: View {
    @EnvironmentObject private var mgr: ErosionManager
    @StateObject private var store = GestaltStore.shared
    @AppStorage("mgOverrideGates") private var mgOverrideGates = false
    @AppStorage("mgWriteAtomically") private var mgWriteAtomically = true
    @AppStorage("mgAutoRespring") private var mgAutoRespring = false
    
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
                            Alertinator.shared.alert(title: "Subtype Info", body: "Only change your subtype if you want to move the dynamic island into a more viewable position. If you're looking to enable the dynamic island, turn on the toggle in this page!")
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
                            PlainToggle(text: "Enable Dynamic Island", minSupportedVersion: 19.0, isOn: store.mgKeyBinding(["YlEtTtHlNesRBMal1CqRaA"]))
                        }
                        if !isAODHD() || mgOverrideGates {
                            PlainToggle(text: "Enable AOD", minSupportedVersion: 18.0, isOn: store.mgKeyBinding(["j8/Omm6s1lsmTDFsXjsBfA", "2OOJf1VhaM7NxfRok3HbWQ"]))
                            
                            if store.mgKeyBinding(["j8/Omm6s1lsmTDFsXjsBfA", "2OOJf1VhaM7NxfRok3HbWQ"]).wrappedValue {
                                PlainToggle(text: "Enable AOD Vibrancy", minSupportedVersion: 18.0, isOn: store.mgKeyBinding(["ykpu7qyhqFweVMKtxNylWA"]))
                            }
                        }
                        if !isBootChimeHD() || mgOverrideGates {
                            PlainToggle(text: "Enable Charge Limit", minSupportedVersion: 17.0, isOn: store.mgKeyBinding(["37NVydb//GP/GrhuTN+exg"]))
                        }
                        if !isChargeLimitHD() || mgOverrideGates {
                            PlainToggle(text: "Enable Boot Chime", isOn: store.mgKeyBinding(["QHxt+hGLaBPbQJbXiUJX3w"]))
                        }
                    } header: {
                        HeaderLabel(text: "Hardware Features", icon: "gearshape")
                    }
                }
                
                if !store.mgKeyBinding(["A62OafQ85EJAiiqKn4agtg"]).wrappedValue {
                    Section {
                        PlainToggle(text: "Enable Internal Install", infoType: .info, infoMessage: mgInfoMessages.internalinstall, isOn: store.mgKeyBinding(["EqrsVvjcYDdxHBiQmGhAWw"]))
                        PlainToggle(text: "Enable Internal Build", isOn: store.mgKeyBinding(["LBJfwOEzExRxzlAnSuI7eg"]))
                    } header: {
                        HeaderLabel(text: "Internal", icon: "ant")
                    }
                }
                
                Section {
                    let cacheExtra = store.mgCurrentDict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
                    PlainToggle(text: "Enable SRD UI", minSupportedVersion: 26.0, isOn: store.mgKeyBinding(["XYlJKKkj2hztRP1NWWnhlw"]))
                    if cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] as? String != "LL" || cacheExtra["yK+xavymRGZ3xWc1tb8XDg"] as? String != "LL/A" {
                        PlainToggle(text: "Disable Region Restrictions", isOn: store.mgRegionRestrictionsBinding())
                    }
                    if !isAppleIntellHD() || mgOverrideGates {
                        PlainToggle(text: "Enable Apple Intelligence", minSupportedVersion: 18.1, isOn: store.mgKeyBinding(["A62OafQ85EJAiiqKn4agtg"]))
                            .onChange(of: store.mgKeyBinding(["A62OafQ85EJAiiqKn4agtg"]).wrappedValue) { (oldVal, newVal) in
                                if newVal {
                                    store.mgPullKeys(["EqrsVvjcYDdxHBiQmGhAWw", "LBJfwOEzExRxzlAnSuI7eg"])
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
                            Alertinator.shared.alert(title: "Device Spoofing Info", body: isAppleIntellHD() ? mgInfoMessages.spoofUseless : mgInfoMessages.spoofAI)
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
                        PlainToggle(text: "Crash Detection", isOn: store.mgKeyBinding(["HCzWusHQwZDea6nNhaKndw"]))
                    }
                    if !isPWMHD() || mgOverrideGates {
                        PlainToggle(text: "Pulse Width Modulation", minSupportedVersion: 19.0, isOn: store.mgKeyBinding(["6IejgN+1Fmu5/QrZFOIeNw"]))
                    }
                    if ogMachineName.contains("iPhone") || mgOverrideGates {
                        PlainToggle(text: "Apple Pencil Settings", isOn: store.mgKeyBinding(["yhHcB0iH0d1XzPO/CFd3ow"]))
                    }
                    if !isCamControlHD() || mgOverrideGates {
                        PlainToggle(text: "Camera Control", minSupportedVersion: 18.0, isOn: store.mgKeyBinding(["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"]))
                    }
                    if !isActionButtonHD() || mgOverrideGates {
                        PlainToggle(text: "Action Button", minSupportedVersion: 17.0, isOn: store.mgKeyBinding(["cT44WE1EohiwRzhsZ8xEsw"]))
                    }
                    if isHomeButtonHD() || mgOverrideGates {
                        PlainToggle(text: "Tap to Wake", isOn: store.mgKeyBinding(["yZf3GTRMGTuwSV/lD7Cagw"]))
                    }
                } header: {
                    HeaderLabel(text: "Preference Bundles", icon: "gear")
                }
                
                Section {
                    let cacheExtra = store.mgCurrentDict["CacheExtra"] as? NSMutableDictionary
                    if machineName().contains("iPad") || mgOverrideGates {
                        PlainToggle(text: "Enable Stage Manager", isOn: store.mgKeyBinding(["qeaj75wk3HF4DwQ8qbIi7g"]))
                    }
                    if cacheExtra?["+3Uf0Pm5F8Xy7Onyvko0vA"] as? String == "iPhone" || mgOverrideGates {
                        PlainToggle(text: "Enable iPadOS UI", infoType: .warning, infoMessage: mgInfoMessages.ipadOSWarning, isOn: store.mgTrollPadBinding())
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
                            Alertinator.shared.alert(title: "Are you sure you'd like to reset MobileGestalt?", body: "Resetting MobileGestalt involves deleting the original cache. This may cause unforseen consequences, such as data loss.", actionLabel: "Confirm", action: {
                                do {
                                    try fm.removeItem(at: currentGestaltURL)
                                    Alertinator.shared.alert(title: "Successfully reset MobileGestalt!", body: "To complete the reset, you'll have to reboot your iPhone.", showCancel: false, actionLabel: "Exit App", action: { exitinator() })
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
                                    Button("Export MobileGestalt") {
                                        presentShareSheet(with: currentGestaltURL)
                                    }
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
                        if store.mgKeyBinding(["A62OafQ85EJAiiqKn4agtg"]).wrappedValue || store.mgTrollPadBinding().wrappedValue {
                            showInfoSheet = true
                        } else {
                            mgApply()
                        }
                    }
                }
            }
            .sheet(isPresented: $showInfoSheet) {
                NavigationStack {
                    VStack {
                        InfoSheet(title: "Before you begin...", cellContent: {
                            InfoSheetCell(icon: "apple.intelligence", title: "Apple Intelligence", context: mgInfoMessages.aiInfo)
                            InfoSheetCell(icon: "ipad", title: "iPadOS UI", context: mgInfoMessages.ipadOSWarning)
                            InfoSheetCell(icon: "exclamationmark.triangle.fill", title: "Important Note!", context: mgInfoMessages.supportWarning)
                        }, buttonContent: {
                            Button("Apply") {
                                mgApply()
                                showInfoSheet = false
                            }
                            .buttonStyle(ConfirmButtonStyle())
                        })
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
                let isWritable = fm.isWritableFile(atPath: currentGestaltURL.path)
                if !isWritable {
                    let res = BadQuery().grantAccess(atPath: currentGestaltURL.deletingLastPathComponent().path, toFileName: "com.apple.MobileGestalt.plist")
                    if !res.0 {
                        Alertinator.shared.alert(title: "Failed to get write access to MobileGestalt!", body: "Tweaks will NOT apply. Maybe try restarting the app?")
                    }
                }
            }
        }
    }
    
    private func mgLoadData() -> NSMutableDictionary {
        do {
            let mgData = try Data(contentsOf: currentGestaltURL)
            if !fm.fileExists(atPath: ogGestaltSavedURL.path) {
                try mgData.write(to: ogGestaltSavedURL)
            }
            
            if let ogDict = NSDictionary(contentsOf: ogGestaltSavedURL),
               let ogCacheExtra = ogDict["CacheExtra"] as? NSDictionary,
               let ogArtwork = ogCacheExtra["oPeik/9e8lQWMszEjbPzng"] as? NSDictionary {
                mgOgSubtype = ogArtwork["ArtworkDeviceSubType"] as? Int ?? 0
                mgOgDeviceName = ogArtwork["ArtworkDeviceProductDescription"] as? String ?? ""
            } else {
                throw "failed to get information from mobilegestalt"
            }
            
            guard let currentDict = NSMutableDictionary(contentsOf: currentGestaltURL) else {
                throw "failed to get nsmutabledictionary from mobilegestalt"
            }
            
            if let cacheExtra = currentDict["CacheExtra"] as? NSDictionary,
               let artwork = cacheExtra["oPeik/9e8lQWMszEjbPzng"] as? NSDictionary {
                mgSubtype = artwork["ArtworkDeviceSubType"] as? Int ?? 0
                mgDeviceName = artwork["ArtworkDeviceProductDescription"] as? String ?? ""
                if mgDeviceName != mgOgDeviceName {
                    mgEnableDeviceName = true
                }
                mgProductType = cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String ?? machineName()
            }
            
            return currentDict
        } catch {
            print("[!] failed to get mobilegestalt: \(error)")
            Alertinator.shared.alert(title: "Failed to get MobileGestalt!", body: "Error: \(error).\n\nThis is really bad. Do NOT apply anything!")
        }
        
        return [:]
    }
    
    private func mgApply() {
        do {
            let mgDictToApply = store.mgCurrentDict
            
            if let cacheExtra = mgDictToApply["CacheExtra"] as? NSMutableDictionary,
               let artwork = cacheExtra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary {
                artwork["ArtworkDeviceSubType"] = mgSubtype
                if mgEnableDeviceName {
                    artwork["ArtworkDeviceProductDescription"] = mgDeviceName
                }
                cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] = mgProductType
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
            guard let mgDictToApply = NSMutableDictionary(contentsOf: ogGestaltSavedURL) else {
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
