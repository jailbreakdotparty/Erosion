//
//  TweaksView.swift
//  Erosion
//
//  Created by lunginspector on 8/26/26.
//

import SwiftUI
import PartyUI

struct TweaksView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Custom Wallpapers", destination: PosterBoardView())
                    NavigationLink("Dialer Themer", destination: KeypadView())
                } header: {
                    HeaderLabel(text: "Theming", icon: "paintbrush")
                }
                
                Section {
                    if raveSupported() || weOnADebugBuild {
                        NavigationLink("MobileGestalt", destination: GestaltView())
                        NavigationLink("Config Tweaks", destination: ConfigView())
                    }
                    NavigationLink("File Operations", destination: OperationsView())
                } header: {
                    HeaderLabel(text: "System", icon: "gear")
                }
            }
            .navigationTitle("Tweaks")
        }
    }
}
