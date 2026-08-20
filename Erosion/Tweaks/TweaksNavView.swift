//
//  TweaksNavView.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI

struct TweaksNavView: View {
    var body: some View {
        NavigationStack {
            List {
                if mgSupported() {
                    NavigationLink("MobileGestalt", destination: GestaltView())
                }
                NavigationLink("PosterBoard", destination: PosterBoardView())
                NavigationLink("File Operations", destination: OperationsView())
            }
            .navigationTitle("Tweaks")
        }
    }
}
