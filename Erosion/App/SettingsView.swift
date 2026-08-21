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
    @AppStorage("showTips") private var showTips = true
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    AppInfoCell(build: build)
                    NavigationLink("Credits") {
                        List {
                            LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Primary developer.", url: "https://github.com/lunginspector")
                            LinkCreditCell(image: Image("forcequit"), name: "forcequit", description: "The bad_query sandbox escape this app relies on.", url: "https://github.com/forcequitOS/bad_query")
                            LinkCreditCell(image: Image("rooootdev"), name: "rooootdev", description: "Various backend things from mond.", url: "https://github.com/rooootdev/mond")
                        }
                        .navigationTitle("Credits")
                    }
                } footer: {
                    Text("Made with love by lunginspector for the [jailbreak.party](https://jailbreak.party) team.\nJoin the [jailbreak.party](https://jailbreak.party/discord) Discord!")
                }
                
                Section {
                    Toggle("Show Tooltips", isOn: $showTips)
                } header: {
                    HeaderLabel(text: "View Options", icon: "eyes")
                } footer: {
                    Text("With tooltips turned off, you will not get prompts that tell you how to use certain parts of the app.")
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
