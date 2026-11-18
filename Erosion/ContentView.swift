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
    
    @AppStorage("pbContainerHash") private var pbContainerHash = ""
    @AppStorage("mpContainerHash") private var mpContainerHash = ""
    @State private var isFetching = false
    @State private var hasAttempted = false
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
                }
                
                Section {
                    TextField("PosterBoard", text: $pbContainerHash)
                    TextField("Phone", text: $mpContainerHash)
                } header: {
                    HeaderLabel("Container Hashes", symbol: "shippingbox")
                } footer: {
                    if hasAttempted {
                        if pbContainerHash.isEmpty && mpContainerHash.isEmpty {
                            Text("PosterBoard and Dialer tweaks will not apply. Try fetching your hashes again.")
                        } else if pbContainerHash.isEmpty {
                            Text("PosterBoard tweaks will not apply. Try fetching your hashes again.")
                        } else if mpContainerHash.isEmpty {
                            Text("Dialer tweaks will not apply. Try fetching your hashes again.")
                        }
                    }
                }
                
                Section {
                    Button {
                        fetchContainerHashes()
                    } label: {
                        HStack {
                            Text(isFetching ? "Fetching..." : "Fetch")
                            if isFetching {
                                Spacer()
                                ProgressView().offset(y: -0.5)
                            }
                        }
                    }
                    .disabled(isFetching)
                    Slider(value: $selection, in: 0...Double(inodeOptions.count - 1), step: 1)
                        .disabled(isFetching)
                } footer: {
                    Text("If either hash doesn't appear, it may help to adjust this slider. Higher values may take longer, but will have a better chance of finding the necessary hashes.")
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
                if pbContainerHash.isEmpty || mpContainerHash.isEmpty {
                    fetchContainerHashes()
                }
            }
        }
    }
    
    private func fetchContainerHashes() {
        DispatchQueue.global(qos: .userInitiated).async {
            isFetching = true
            mpContainerHash = ""
            pbContainerHash = ""
            leakedPaths = fsHandlers.getDirPaths(FSPaths.appContainers, maxInode: inode)
            if let mpNewHash = fsHandlers.getContainerPath(leakedPaths, forMatch: "com.apple.mobilephone", hashOnly: true) {
                mpContainerHash = mpNewHash
            }
            if let pbNewHash = fsHandlers.getContainerPath(leakedPaths, forMatch: "com.apple.PosterBoard", hashOnly: true) {
                pbContainerHash = pbNewHash
            }
            hasAttempted = true
            isFetching = false
        }
    }
}

#Preview {
    ContentView()
}
