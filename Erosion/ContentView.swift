//
//  ContentView.swift
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

import SwiftUI


struct ContentView: View {
    @AppStorage("ogMachineName") var ogMachineName = ""
    @EnvironmentObject var mgr: ErosionManager
    @State private var showSettings = false
    
    @State private var isFetching = false
    @State private var selection: Double = 0
    @State private var leakedPaths = [String]()
    private let inodeOptions: [Double] = [100000, 2500000, 5000000, 7500000, 10000000]
    
    private var inode: Int { Int(inodeOptions[Int(selection)]) }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .modifier(TerminalPlatter())
                } header: {
                    HeaderLabel("Logs", symbol: "apple.terminal")
                }
                
                Section {
                    Button("Respring") {
                        mgr.shouldRespring = true
                    }
                } header: {
                    HeaderLabel("Actions", symbol: "gear")
                }
            }
            .navigationTitle("Erosion")
            .listStyle(.insetGrouped)
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
                if mgr.pbContainerHash.isEmpty || mgr.mpContainerHash.isEmpty {
                    DispatchQueue.global(qos: .userInitiated).async {
                        mgr.isFetching = true
                        let _ = mgr.getHashesRamp()
                        mgr.isFetching = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
