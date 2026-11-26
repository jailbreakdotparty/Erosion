//
//  SettingsView.swift
//  Erosion
//
//  Created by lunginspector on 8/20/26.
//

import SwiftUI

struct InodeOption: Identifiable, Hashable {
    var id: String { String(value) }
    var label: String
    var value: Int
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mgr: ErosionManager
    @AppStorage("autoRespring") var autoRespring = false
    
    @State private var selection: Double = 0
    @State private var leakedPaths = [String]()
    
    private let inodeOptions: [InodeOption] = [
        InodeOption(label: "Low", value: 100000),
        InodeOption(label: "Medium", value: 2500000),
        InodeOption(label: "High", value: 5000000),
        InodeOption(label: "Extreme", value: 7500000),
        InodeOption(label: "Max", value: 10000000)
    ]
    
    @State private var inode: Int = 100000
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("PosterBoard", text: $mgr.pbContainerHash)
                        .disabled(mgr.isFetching)
                    TextField("Phone", text: $mgr.mpContainerHash)
                        .disabled(mgr.isFetching)
                    HStack {
                        Button {
                            DispatchQueue.global(qos: .userInitiated).async {
                                mgr.isFetching = true
                                let _ = mgr.fetchContainerHashes(withInode: inode)
                                mgr.isFetching = false
                            }
                        } label: {
                            HStack {
                                if mgr.isFetching {
                                    ProgressView().offset(y: -0.5)
                                }
                                Text(mgr.isFetching ? "Fetching..." : "Fetch")
                            }
                        }
                        .disabled(mgr.isFetching)
                        .buttonStyle(.plain)
                        .foregroundStyle(mgr.isFetching ? .secondary : Color.accentColor)
                        Spacer()
                        Picker("Max Inode", selection: $inode) {
                            ForEach(inodeOptions) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                        .disabled(mgr.isFetching)
                        .labelsHidden()
                        .padding(.vertical, -6)
                    }
                } header: {
                    HeaderLabel("Container Hashes", symbol: "shippingbox")
                } footer: {
                    Text("If hashes do not appear, it may help to adjust the fetching intensity. Higher options will take longer.")
                }
                
                Section {
                    Toggle("Auto-Respring", isOn: $autoRespring)
                } header: {
                    HeaderLabel("App Settings", symbol: "gearshape")
                } footer: {
                    Text("Automatically resprings your device after applying a tweak.")
                }
                
                Section {
                    AppInfoCell(build: build)
                    NavigationLink(destination: AcknowledgementsView(), label: { Text("Acknowledgements") })
                } header: {
                    HeaderLabel("About", symbol: "info.circle")
                } footer: {
                    Text("Made with love by the [jailbreak.party](https://jailbreak.party) team.")
                }
                
                Section {
                    LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Primary developer, tweaks, UI, and file browser.", url: "https://github.com/lunginspector")
                    LinkCreditCell(image: Image("skadz108"), name: "Skadz", description: "Project maintainer and developer, various fixes and backend work.", url: "https://github.com/skadz108")
                    LinkCreditCell(image: Image("forcequit"), name: "forcequit", description: "worse_query sandbox escape and container enumeration strategy.", url: "https://github.com/forcequitOS")
                    LinkCreditCell(image: Image("0xjohnny"), name: "0xjohnny", description: "worse_query sandbox escape.", url: "https://github.com/0xjohnnydev")
                    LinkCreditCell(image: Image("rooootdev"), name: "rooootdev", description: "Various backend components.", url: "https://github.com/rooootdev")
                    LinkCreditCell(image: Image("neonmodder123"), name: "neonmodder123", description: "Developed WebView respring method.", url: "https://github.com/neonmodder123")
                } header: {
                    HeaderLabel("Credits", symbol: "star")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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

// Skadz 2026-11-09: pretty disgusting but its what we doing.
struct AcknowledgementsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    NavigationLink(destination: {
                        VStack {
                            ScrollView {
                                VStack {
                                    Text(try! String(contentsOf: Bundle.main.url(forResource: "worse_query_LICENSE", withExtension: "txt")!, encoding: .utf8))
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 14))
                                }
                                .navigationTitle("worse_query")
                            }
                        }
                    }, label: { Text("worse_query")})
                    
                    NavigationLink(destination: {
                        VStack {
                            ScrollView {
                                VStack {
                                    Text(try! String(contentsOf: Bundle.main.url(forResource: "PrivateKits_LICENSE", withExtension: "txt")!, encoding: .utf8))
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 14))
                                }
                                .navigationTitle("PrivateKits")
                            }
                        }
                    }, label: { Text("PrivateKits")})
                }
            }
            .navigationTitle("Acknowledgements")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
