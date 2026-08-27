//
//  TweaksView.swift
//  Erosion
//
//  Created by lunginspector on 8/26/26.
//

import SwiftUI

struct TweaksView: View {
    var body: some View {
        NavigationStack {
            List {
                if raveSupported() || weOnADebugBuild {
                    NavigationLink("MobileGestalt", destination: GestaltView())
                    NavigationLink("Config Tweaks", destination: ConfigView())
                }
                NavigationLink("Custom Wallpapers", destination: PosterBoardView())
                NavigationLink("File Operations", destination: OperationsView())
            }
            .navigationTitle("Tweaks")
        }
    }
}
