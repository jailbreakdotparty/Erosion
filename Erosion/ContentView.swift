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
                    Text("Made with love by the [jailbreak.party](https://jailbreak.party/) team. Thanks to forcequitOS for the [bad_query](https://github.com/forcequitOS/bad_query) sandbox escape that this app relies on.")
                }
                
                Section {
                    if mgSupported() || weOnADebugBuild {
                        NavigationLink("MobileGestalt", destination: GestaltView())
                        NavigationLink("Config Tweaks", destination: ConfigView())
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
                    Button {
                        mgr.shouldRespring = true
                    } label: {
                        Label("Respring", systemImage: "goforward")
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
