//
//  HomeView.swift
//  Erosion
//
//  Created by lunginspector on 8/26/26.
//

import SwiftUI
import PartyUI

struct HomeView: View {
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
                    HeaderLabel(text: "Version \(AppInfo.appVersion) (\(build))", icon: "info.circle")
                } footer: {
                    Text("Made with love by the [jailbreak.party](https://jailbreak.party/) team. Thanks to forcequitOS for the [bad_query](https://github.com/forcequitOS/bad_query) sandbox escape that this app relies on.")
                }
                
                Section {
                    Button("Respring") {
                        mgr.shouldRespring = true
                    }
                } header: {
                    HeaderLabel(text: "Actions", icon: "gearshape")
                }
            }
            .navigationTitle("Erosion")
            .toolbar {
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
