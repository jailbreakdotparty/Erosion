//
//  ConfigView.swift
//  Erosion
//
//  Created by lunginspector on 8/21/26.
//

import SwiftUI
import PartyUI

enum FSURL {
    static var sysGroup = URL(fileURLWithPath: "/private/var/containers/Shared/SystemGroup")
    static var configProfiles = FSURL.sysGroup.appendingPathComponent("systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles")
}

enum CNURL {
    static var sharedDevConfig = FSURL.configProfiles.appendingPathComponent("SharedDeviceConfiguration.plist")
    static var cloudConfig = FSURL.configProfiles.appendingPathComponent("CloudConfigurationDetails.plist")
}

enum CNMsg {
    static var supWarning = "If you're using this tweak and your device is already MDM-configured, do NOT touch this toggle! Also, and this goes for all users, you may see a setup screen after respringing. Use at your own risk."
    static var resetInfo = "By clicking \"Confirm\", your footnote will be removed and your device will be unsupervised."
}

struct ConfigView: View {
    @EnvironmentObject private var mgr: ErosionManager
    @AppStorage("showTips") private var showTips = false
    @State private var ftCurrentDict = NSMutableDictionary()
    @State private var ccCurrentDict = NSMutableDictionary()
    @State private var footnoteText = ""
    @State private var supervised = false
    @State private var orgName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 14) {
                        HStack {
                            Image(systemName: "flashlight.off.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .padding()
                                .modifier(QuickActionBackground())
                            Spacer()
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .padding()
                                .modifier(QuickActionBackground())
                        }
                        .padding(.horizontal, 35)
                        
                        VStack {
                            Text(footnoteText)
                                .font(.system(size: 9))
                                .frame(height: 10)
                            Capsule()
                                .frame(width: 145, height: 4)
                        }
                    }
                    .padding(.top, 25)
                    .padding(.bottom, 10)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        Group {
                            Image("solarium")
                                .resizable()
                                .scaledToFill()
                                .offset(y: 10)
                        }
                    )
                    
                    TextField("Custom Footnote", text: $footnoteText)
                }
                
                Section {
                    PlainToggle(text: "Enable Supervision", infoType: .warning, infoTitle: "Supervision Warning!", infoMessage: CNMsg.supWarning, isOn: $supervised)
                    if supervised {
                        TextField("Organization Name", text: $orgName)
                    }
                } header: {
                    HeaderLabel(text: "Supervision", icon: "eye")
                }
            }
            .navigationTitle("Configurations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if showTips {
                            Alertinator.shared.alert(title: "Are you sure you'd like to reset your tweaks?", body: CNMsg.resetInfo, actionLabel: "Confirm", action: {
                                reset()
                            })
                        } else {
                            reset()
                        }
                    } label: {
                        Label("Restore Tweaks", systemImage: "gobackward")
                            .labelStyle(.iconOnly)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply", role: .adaptiveConfirm) {
                        apply()
                    }
                }
            }
            .onAppear {
                doSetup()
            }
        }
    }
    
    private func doSetup() {
        if !fm.isWritableFile(atPath: CNURL.sharedDevConfig.path) {
            let res = bq.grantAccess(atPath: FSURL.configProfiles.path)
            if !res.0 {
                Alertinator.shared.alert(title: "Failed to get write access!", body: AppMsg.opFailed)
                return
            }
        }
        if !fm.fileExists(atPath: CNURL.sharedDevConfig.path) {
            do {
                let dict = ["LockScreenFootnote" : ""]
                let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
                try data.write(to: CNURL.sharedDevConfig)
            } catch {
                print("(ft) failed to create footnote file: \(error)")
                Alertinator.shared.alert(title: "Failed to create footnote file!", body: AppMsg.opFailed)
            }
        }
        loadData()
    }
    
    private func loadData() {
        if let ftDict = NSMutableDictionary(contentsOf: CNURL.sharedDevConfig) {
            ftCurrentDict = ftDict
            footnoteText = ftDict["LockScreenFootnote"] as? String ?? ""
        }
        if let ccDict = NSMutableDictionary(contentsOf: CNURL.cloudConfig) {
            ccCurrentDict = ccDict
            supervised = ccDict["IsSupervised"] as? Bool ?? false
            orgName = ccDict["OrganizationName"] as? String ?? ""
        }
    }
    
    private func apply() {
        let ftDict = ["LockScreenFootnote" : footnoteText]
        ccCurrentDict["IsSupervised"] = supervised
        ccCurrentDict["OrganizationName"] = orgName
        do {
            let ftData = try PropertyListSerialization.data(fromPropertyList: ftDict, format: .binary, options: 0)
            try ftData.write(to: CNURL.sharedDevConfig)
            let ccData = try PropertyListSerialization.data(fromPropertyList: ccCurrentDict, format: .binary, options: 0)
            try ccData.write(to: CNURL.cloudConfig)
            print("(cn) successfully applied config tweaks!")
            Haptic.shared.play(.soft)
            if showTips {
                Alertinator.shared.alert(title: "Successfully appiled config tweaks!", body: AppMsg.applied, actionLabel: "Respring", action: { mgr.shouldRespring = true })
            }
        } catch {
            print("(cn) failed to write config files: \(error)")
            Alertinator.shared.alert(title: "Failed to apply tweaks!", body: AppMsg.opFailed)
        }
    }
    
    private func reset() {
        ccCurrentDict["IsSupervised"] = false
        ccCurrentDict.removeObject(forKey: "OrganizationName")
        do {
            try fm.removeItem(at: CNURL.sharedDevConfig)
            let ccData = try PropertyListSerialization.data(fromPropertyList: ccCurrentDict, format: .binary, options: 0)
            try ccData.write(to: CNURL.cloudConfig)
            print("(cn) successfully reset config tweaks!")
            Haptic.shared.play(.soft)
            if showTips {
                Alertinator.shared.alert(title: "Successfully reset config tweaks!", body: AppMsg.applied, actionLabel: "Respring", action: { mgr.shouldRespring = true })
            }
        } catch {
            print("(cn) failed to reset config files: \(error)")
            Alertinator.shared.alert(title: "Failed to reset tweaks!", body: AppMsg.opFailed)
        }
    }
}

// MARK: ui
struct QuickActionBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 19.0, *) {
            content
                .glassEffect(.clear.interactive(), in: .circle)
        } else {
            content
                .background(.ultraThinMaterial, in: .circle)
        }
    }
}
