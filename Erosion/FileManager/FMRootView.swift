//
//  FMRootView.swift
//  Erosion
//
//  Created by lunginspector on 8/26/26.
//

import SwiftUI

enum FSPaths {
    static let appContainers = "/var/mobile/Containers/Data/Application"
    static var appBundles = "/var/containers/Bundle/Application"
}

enum FSURL {
    static let appContainers = URL(fileURLWithPath: FSPaths.appContainers)
    static var sysGroup = URL(fileURLWithPath: "/var/containers/Shared/SystemGroup")
    static var configProfiles = FSURL.sysGroup.appendingPathComponent("systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles")
    static var internalDaemons = URL(fileURLWithPath: "/var/mobile/Containers/Data/InternalDaemon")
    static var appPlugins = URL(fileURLWithPath: "/var/mobile/Containers/Data/PluginKitPlugin")
    static var appGroup = URL(fileURLWithPath: "/var/mobile/Containers/Shared/AppGroup")
    static var systemData = URL(fileURLWithPath: "/var/containers/Data/System")
}

struct FMRootView: View {
    @State private var showSettingsSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Data Containers", destination: FileBrowserView(path: FSURL.appContainers, isContainer: true))
                    NavigationLink("Plugin Containers", destination: FileBrowserView(path: FSURL.appPlugins, isContainer: true))
                    NavigationLink("App Groups", destination: FileBrowserView(path: FSURL.appGroup, shouldGrant: true))
                } header: {
                    HeaderLabel("Apps", symbol: "square.grid.2x2")
                }
                
                Section {
                    NavigationLink("Daemon Containers", destination: FileBrowserView(path: FSURL.internalDaemons, isContainer: true))
                    NavigationLink("System Containers", destination: FileBrowserView(path: FSURL.systemData, shouldGrant: true))
                    NavigationLink("SystemGroup Containers", destination: FileBrowserView(path: FSURL.sysGroup, isContainer: true))
                } header: {
                    HeaderLabel("System", symbol: "gear")
                }
            }
            .navigationTitle("File Browser")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettingsSheet = true
                    } label: {
                        Label("Settings", systemImage: "gear").labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $showSettingsSheet) {
                FMSettings()
            }
        }
    }
}
