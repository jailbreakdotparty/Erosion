//
//  FolderRow.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI
import PartyUI
import QuickLook
import ZIPFoundation

struct FolderRow: View {
    @EnvironmentObject var mgr: ErosionManager
    var file: FileItem
    var shouldGrant: Bool
    var isContainer: Bool = false
    
    @State private var previewURL: URL?
    @State private var folderType: FolderType = .normal
    
    @State private var showInfo = false
    
    var body: some View {
        NavigationLink(destination: FileBrowserView(path: file.destURL, shouldGrant: shouldGrant)) {
            HStack(spacing: isSolariumUI() ? 12 : 10) {
                Group {
                    Image(systemName: "folder")
                        .frame(width: 20, alignment: .center)
                        .foregroundStyle(file.hidden ? .secondary : .primary)
                    Text(file.name)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(file.hidden ? .secondary : .primary)
                }
                
                Spacer()
                
                Button {
                    showInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .foregroundStyle(file.hidden ? .secondary : .primary)
            }
        }
        .foregroundStyle(Color(.label))
        .onAppear {
            folderType = getFolderType(url: file.fileURL)
        }
        .sheet(isPresented: $showInfo) {
            InfoViewer(file)
        }
        .quickLookPreview($previewURL)
        .contextMenu {
            if !isContainer {
                Button {
                    previewURL = file.fileURL
                } label: {
                    Label("Quick Look", systemImage: "eye")
                }
                
                Divider()
                
                Button {
                    showInfo.toggle()
                } label: {
                    Label("Get Info", systemImage: "info.circle")
                }
                
                Button {
                    let res = zipFile(file.fileURL)
                    if res {
                        mgr.refreshFiles.toggle()
                    } else {
                        Alertinator.shared.alert(title: "Failed to compress file!", body: Errors.checkLogs)
                    }
                } label: {
                    Label("Compress", systemImage: "archivebox")
                }
                
                Divider()
                
                Button {
                    if let url = makeTemp(file.fileURL) {
                        presentShareSheet(with: url)
                    }
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    try? fm.removeItem(at: file.fileURL)
                    mgr.refreshFiles.toggle()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
