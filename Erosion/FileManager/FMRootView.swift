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
    var body: some View {
        NavigationStack {
            List {
                Section("Data Containers") {
                    NavigationLink("Applications", destination: FileBrowserView(path: FSURL.appContainers, isContainer: true))
                    NavigationLink("Daemons", destination: FileBrowserView(path: FSURL.internalDaemons, isContainer: true))
                    NavigationLink("App Plugins", destination: FileBrowserView(path: FSURL.appPlugins, isContainer: true))
                }
                
                if raveSupported() {
                    Section("Other Containers") {
                        NavigationLink("App Groups", destination: FileBrowserView(path: FSURL.appGroup, shouldGrant: true))
                        NavigationLink("System App Data", destination: FileBrowserView(path: FSURL.systemData, shouldGrant: true))
                        NavigationLink("SystemGroup Containers", destination: FileBrowserView(path: FSURL.sysGroup, isContainer: true))
                    }
                }
            }
            .navigationTitle("File Browser")
        }
    }
}
