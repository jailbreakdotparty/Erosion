//
//  SettingsView.swift
//  Erosion
//
//  Created by lunginspector on 8/20/26.
//

import SwiftUI
import PartyUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("showTips") var showTips = true
    @AppStorage("autoRespring") var autoRespring = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Show Tooltips", isOn: $showTips)
                    Toggle("Respring on Apply", isOn: $autoRespring)
                } header: {
                    HeaderLabel(text: "View Options", icon: "eye")
                }
                
                Section {
                    NavigationLink {
                        List {
                            LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Primary developer", url: "https://github.com/lunginspector")
                            LinkCreditCell(image: Image("forcequit"), name: "forcequit", description: "bad_query sandbox escape", url: "https://github.com/forcequitOS")
                            LinkCreditCell(image: Image("rooootdev"), name: "rooootdev", description: "Various backend components", url: "https://github.com/rooootdev")
                        }
                        .navigationTitle("Credits")
                    } label: {
                        AppInfoCell(build: build)
                    }
                } footer: {
                    Text("Made with love by the [jailbreak.party](https://jailbreak.party) team.\nNeed support or want to know about new releases? Join our [jailbreak.party](Discord!)")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ToolbarLabel("Close", icon: "xmark")
                    }
                }
            }
        }
    }
}
