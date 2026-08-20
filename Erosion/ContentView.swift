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
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .modifier(TerminalPlatter())
                } header: {
                    HeaderLabel(text: "Version 0.1 (\(build))", icon: "info.circle")
                } footer: {
                    Text("Created by lunginspector using the [bad_query](https://gist.github.com/lunginspector/10d2fe2a244175562a3f665f1cf2366f) exploit. Do NOT ask for any support in [jailbreak.party](https://jailbreak.party)'s support server regarding this build!")
                }
                
                Section {
                    Button("Respring") {
                        mgr.shouldRespring = true
                    }
                } header: {
                    HeaderLabel(text: "Actions", icon: "wrench.and.screwdriver")
                }
            }
            .navigationTitle("Erosion")
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
