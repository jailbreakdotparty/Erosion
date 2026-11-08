//
//  SettingsView.swift
//  Erosion
//
//  Created by lunginspector on 8/20/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("autoRespring") var autoRespring = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Auto-Respring", isOn: $autoRespring)
                } header: {
                    HeaderLabel("App Settings", symbol: "gearshape")
                } footer: {
                    Text("Automatically resprings your device after applying a tweak.")
                }
                
                Section {
                    AppInfoCell(build: build)
                } header: {
                    HeaderLabel("About", symbol: "info.circle")
                } footer: {
                    Text("Made with love by the [jailbreak.party](https://jailbreak.party) team.")
                }
                
                Section {
                    LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Primary developer and maintainer.", url: "https://github.com/lunginspector")
                    LinkCreditCell(image: Image("forcequit"), name: "forcequit", description: "worse_query sandbox escape.", url: "https://github.com/forcequitOS")
                    LinkCreditCell(image: Image("0xjohnny"), name: "0xjohnny", description: "worse_query sandbox escape.", url: "https://github.com/0xjohnnydev")
                    LinkCreditCell(image: Image("skadz108"), name: "Skadz", description: "Exploit implementation, backend functions, and project maintainer.", url: "https://github.com/skadz108")
                    LinkCreditCell(image: Image("rooootdev"), name: "rooootdev", description: "Various backend components.", url: "https://github.com/rooootdev")
                    LinkCreditCell(image: Image("neonmodder123"), name: "neonmodder123", description: "Developed WebView respring method.", url: "https://github.com/neonmodder123")
                } header: {
                    HeaderLabel("Credits", symbol: "star")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ToolbarLabel("Close", symbol: "xmark")
                    }
                }
            }
        }
    }
}
