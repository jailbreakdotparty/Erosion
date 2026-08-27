//
//  TextViewer.swift
//  Filos
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI
import PartyUI

struct TextViewer: View {
    @EnvironmentObject var mgr: ErosionManager
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("textViewerSize") var textViewerSize = 11
    @AppStorage("useMonospaced") var useMonospaced = true
    
    var fileURL: URL
    
    @State private var file = clearFileItem
    @State private var fileText = ""
    @State private var editText = ""
    @State private var isEditing = false
    
    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if isEditing {
                        TextEditor(text: $editText)
                            .font(.system(size: CGFloat(textViewerSize), design: useMonospaced ? .monospaced : .default))
                    } else {
                        Text(fileText)
                            .font(.system(size: CGFloat(textViewerSize), design: useMonospaced ? .monospaced : .default))
                            .padding(5)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 100, alignment: .topLeading)
            }
            .navigationTitle(fileURL.deletingPathExtension().lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .safeAreaInset(edge: .bottom) {
                if !file.writable {
                    HStack {
                        Spacer()
                        Button {
                            Alertinator.shared.alert(title: "View-Only File", body: "You can only read this file.")
                        } label: {
                            Image(systemName: "lock")
                                .padding(10)
                        }
                        .foregroundStyle(Color.accentColor)
                        .padding(.trailing)
                        .ignoresSafeArea()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isEditing {
                        Button {
                            isEditing = false
                            editText = fileText
                        } label: {
                            ToolbarLabel("Cancel", icon: "xmark")
                        }
                    }
                    
                    Menu {
                        if file.writable && !isEditing {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        
                        Button {
                            Haptic.shared.play(.soft)
                            UIPasteboard.general.string = fileText
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            if let url = makeTemp(fileURL) {
                                presentShareSheet(with: url)
                            }
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button(role: .adaptiveConfirm) {
                            let res = writeTextIntoFile(fileURL, string: editText)
                            if res {
                                isEditing = false
                                fileText = getFileText(fileURL)
                            }
                        } label: {
                            ToolbarLabel("Save", icon: "checkmark")
                        }
                    } else {
                        Button {
                            dismiss()
                            mgr.refreshFiles.toggle()
                        } label: {
                            ToolbarLabel("Close", icon: "xmark")
                        }
                    }
                }
            }
            .onAppear {
                file = getFileItem(at: fileURL)
                let text = getFileText(fileURL)
                fileText = text
                editText = text
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func writeTextIntoFile(_ url: URL, string: String) -> Bool {
        do {
            let data = Data(string.utf8)
            try data.write(to: url)
            return true
        } catch {
            print("[!] failed to write data: \(error)")
        }
        return false
    }
}
