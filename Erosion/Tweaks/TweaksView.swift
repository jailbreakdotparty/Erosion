//
//  TweaksView.swift
//  Erosion
//
//  Created by lunginspector on 8/26/26.
//

import SwiftUI


struct TweaksView: View {
    @AppStorage("pbContainerHash") private var pbContainerHash = ""
    @AppStorage("mpContainerHash") private var mpContainerHash = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Custom Wallpapers", destination: PosterBoardView()).disabled(pbContainerHash.isEmpty)
                    NavigationLink("Dialer Themer", destination: KeypadView()).disabled(mpContainerHash.isEmpty)
                } header: {
                    HeaderLabel("Theming", symbol: "paintbrush")
                }
                
                Section {
                    if raveSupported() || AppInfo.isDebug {
                        NavigationLink("MobileGestalt", destination: GestaltView())
                    }
                    NavigationLink("Config Tweaks", destination: ConfigView())
                    NavigationLink("File Operations", destination: OperationsView())
                } header: {
                    HeaderLabel("System", symbol: "gear")
                }
            }
            .navigationTitle("Tweaks")
        }
    }
}
