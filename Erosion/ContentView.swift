//
//  ContentView.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI
import PartyUI

struct ContentView: View {
    @AppStorage("ogMachineName") var ogMachineName = ""
    @EnvironmentObject var mgr: ErosionManager
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .modifier(TerminalPlatter())
                } header: {
                    HeaderLabel(text: "Version 0.1 (\(build))", icon: "info.circle")
                } footer: {
                    Text("Made with spite by lunginspector using the [bad_query](https://gist.github.com/lunginspector/10d2fe2a244175562a3f665f1cf2366f) exploit. This project was made under [jailbreak.party](https://jailbreak.party/).")
                }
                
                Section {
                    if mgSupported() || weOnADebugBuild {
                        NavigationLink("MobileGestalt", destination: GestaltView())
                    }
                    NavigationLink("Custom Wallpapers", destination: PosterBoardView())
                    NavigationLink("File Operations", destination: OperationsView())
                } header: {
                    HeaderLabel(text: "Tweaks", icon: "wrench.and.screwdriver")
                }
            }
            .navigationTitle("Erosion")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Text("\(machineName()) • \(device.systemName) \(device.systemVersion) (\(buildNumber()))")
                        Button {
                            mgr.shouldRespring = true
                        } label: {
                            Label("Respring", systemImage: "goforward")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                if ogMachineName.isEmpty {
                    ogMachineName = machineName()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
