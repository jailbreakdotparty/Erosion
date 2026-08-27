//
//  ContentView.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI
import PartyUI

struct ContentView: View {
    @State private var currentTab = 0
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .id(0)
            TweaksView()
                .tabItem {
                    Label("Tweaks", systemImage: "wrench.and.screwdriver")
                }
                .id(1)
            FMRootView()
                .tabItem {
                    Label("File Browser", systemImage: "folder")
                }
        }
    }
}

#Preview {
    ContentView()
}
