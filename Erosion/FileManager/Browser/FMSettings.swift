//
//  FMSettings.swift
//  Erosion
//
//  Created by lunginspector on 11/25/26.
//

import SwiftUI

struct FMSettings: View {
    @AppStorage("maxInode") var maxInode = 7500000
    @AppStorage("chosenSort") var chosenSort: FileSortMode = .system
    @AppStorage("filesAscend") var filesAscend = true
    @AppStorage("listStyle") var listStyle = 1
    @AppStorage("hideDates") var hideDates = false
    @AppStorage("textViewerSize") var textViewerSize = 10
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("autoRefresh") var autoRefresh = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Max Inode")
                        TextField("7500000", value: $maxInode, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Auto Refresh", isOn: $autoRefresh)
                } header: {
                    HeaderLabel("Container Fetching", symbol: "externaldrive")
                } footer: {
                    Text("This controls how quickly files can load. Lower values = faster fetching but less files.")
                }
                
                Section {
                    Picker("List Style", selection: $listStyle) {
                        Text("Default").tag(1)
                        Text("Plain").tag(2)
                        Text("Grouped").tag(3)
                    }
                    Toggle("Hide Dates", isOn: $hideDates)
                } header: {
                    HeaderLabel("View Options", symbol: "eye")
                }
                
                Section {
                    Stepper(value: $textViewerSize) {
                        HStack {
                            Text("Text Size")
                            Spacer()
                            Text(textViewerSize.description)
                        }
                    }
                    Toggle("Monospaced Font", isOn: $useMonospaced)
                } header: {
                    HeaderLabel("Text Viewer", symbol: "doc.plaintext")
                }
            }
            .navigationTitle("File Browser Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark").labelStyle(.iconOnly)
                    }
                }
            }
        }
    }
}
