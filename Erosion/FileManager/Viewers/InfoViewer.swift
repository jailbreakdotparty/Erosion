//
//  FileInfoSheet.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI
import PartyUI
import UniformTypeIdentifiers

struct InfoViewer: View {
    @Environment(\.dismiss) var dismiss
    var file: FileItem
    
    init(_ file: FileItem) {
        self.file = file
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    StringInfoCell(file.name, label: "Name")
                    StringInfoCell(file.fileURL.path, label: "Path")
                    if file.type == .symlink {
                        StringInfoCell(file.destURL.path, label: "Destination Path")
                    }
                    if file.type == .file {
                        StringInfoCell("\(ByteCountFormatter.string(fromByteCount: Int64(file.size), countStyle: .file))", label: "Size")
                    }
                }
                
                Section {
                    StringInfoCell(file.uttype.identifier, label: "UTType")
                    StringInfoCell(file.creationDateStr, label: "Creation Date")
                    StringInfoCell(file.modifiedDateStr, label: "Last Modified")
                    BoolInfoCell(file.type == .symlink, label: "Symlink")
                } header: {
                    HeaderLabel(text: "File", icon: "doc")
                }
                
                Section {
                    StringInfoCell(file.posixPerms, label: "POSIX Permissions")
                    StringInfoCell(file.owner, label: "Owner")
                    StringInfoCell(file.group, label: "Group")
                    BoolInfoCell(file.readable, label: "Readable")
                    BoolInfoCell(file.writable, label: "Writable")
                    BoolInfoCell(file.executable, label: "Executable")
                } header: {
                    HeaderLabel(text: "Permissions", icon: "shield")
                }
            }
            .navigationTitle("\(file.type.rawValue.capitalized) Info")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
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
        .navigationViewStyle(.stack)
    }
    
    private struct StringInfoCell: View {
        var string: String
        var label: String
        
        init(_ string: String, label: String) {
            self.string = string
            self.label = label
        }
        
        var body: some View {
            HStack {
                Text(label)
                Spacer()
                Text(string)
                    .foregroundStyle(.secondary)
            }
            .contextMenu {
                Button {
                    UIPasteboard.general.string = string
                } label: {
                    Label("Copy Value", systemImage: "doc.on.doc")
                }
            }
        }
    }
    
    private struct BoolInfoCell: View {
        var bool: Bool
        var label: String
        
        init(_ bool: Bool, label: String) {
            self.bool = bool
            self.label = label
        }
        
        var body: some View {
            HStack {
                Text(label)
                Spacer()
                Image(systemName: bool ? "checkmark" : "xmark")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
