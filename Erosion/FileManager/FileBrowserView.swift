//
//  FileBrowserView.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/12/26.
//

import SwiftUI
import PartyUI
import QuickLook

enum FileSortMode: String, CaseIterable, Codable, Hashable {
    case system, name, date, type, size
    
    var id: String { label }
    
    var label: String {
        switch self {
        case .system: return "Default"
        case .name: return "Name"
        case .date: return "Date"
        case .type: return "Type"
        case .size: return "Size"
        }
    }
}

struct FileBrowserView: View {
    @EnvironmentObject var mgr: ErosionManager
    var path: URL = URL(fileURLWithPath: "/")
    var isContainer = false
    var shouldGrant = false
    
    @State private var dirFiles: [FileItem] = []
    @State private var unfilteredFiles: [FileItem] = []
    @State private var searchText = ""
    @AppStorage("chosenSort") var chosenSort: FileSortMode = .system
    @AppStorage("filesAscend") var filesAscend: Bool = true
    @AppStorage("listStyle") var listStyle = 1
    @AppStorage("hideDates") var hideDates = false
    @AppStorage("textViewerSize") var textViewerSize = 10
    @AppStorage("useMonospaced") var useMonospaced = true
    
    @State private var showFileImporter = false
    @State private var showFailure = false
    @State private var failMsg = ""
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                Section {
                    HStack {
                        ProgressView()
                            .offset(y: 0.5)
                        Text("Loading Files...")
                            .fontWeight(.medium)
                    }
                }
            } else if showFailure {
                CompactAlert(title: "Failed to load files from directory!", icon: "folder.badge.questionmark", text: failMsg)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            } else {
                ForEach(dirFiles) { file in
                    if file.type == .folder {
                        FolderRow(file: file, shouldGrant: isContainer ? true : false, isContainer: isContainer)
                    } else {
                        FileRow(file: file)
                    }
                }
            }
        }
        .navigationTitle(path.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .customListStyle(listStyle)
        .adaptiveListMargin()
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(FileSortMode.allCases, id: \.self) { option in
                        Button {
                            chosenSort = option
                        } label: {
                            if chosenSort == option {
                                Label(option.label, systemImage: "checkmark")
                                    .tag(option)
                            } else {
                                Text(option.label)
                                    .tag(option)
                            }
                        }
                    }
                    Divider()
                    Button {
                        filesAscend.toggle()
                    } label: {
                        if filesAscend {
                            Label("Ascending", systemImage: "chevron.up")
                        } else {
                            Label("Descending", systemImage: "chevron.down")
                        }
                    }
                    .disabled(chosenSort == .system)
                } label: {
                    Label("Sort", systemImage: "line.3.horizontal.decrease")
                }
                .labelStyle(.iconOnly)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if !isContainer {
                        Menu {
                            Button {
                                Alertinator.shared.prompt(title: "What would you like to call your new file? Make sure you attach an extension at the end.", placeholder: "new.txt", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            let fileURL = path.appendingPathComponent(name)
                                            try Data().write(to: fileURL)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create file: \(error)")
                                            Alertinator.shared.alert(title: "Failed to create file!", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("File", systemImage: "doc")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "What would you like to call your new property list?", placeholder: "Plist Name", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            let fileURL = path.appendingPathComponent(name + ".plist")
                                            let data = try PropertyListSerialization.data(fromPropertyList: NSMutableDictionary(), format: .xml, options: 0)
                                            try data.write(to: fileURL)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create plist: \(error)")
                                            Alertinator.shared.alert(title: "Failed to create property list!", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("Property List", systemImage: "tablecells")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "What would you like to call your new folder?", placeholder: "Folder Name", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            try fm.createDirectoryIfNeeded(at: path.appendingPathComponent(name))
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create folder: \(error)")
                                            Alertinator.shared.alert(title: "Failed to create folder!", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("Folder", systemImage: "folder")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "Where would you like your new symlink to point to?", placeholder: "/path/to/dir", completion: { symPath in
                                    let symPath = symPath ?? ""
                                    if !symPath.isEmpty {
                                        do {
                                            try fm.createSymbolicLink(atPath: path.appendingPathComponent(URL(fileURLWithPath: symPath).lastPathComponent).path, withDestinationPath: symPath)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create symlink: \(error)")
                                            Alertinator.shared.alert(title: "Failed to create symlink!", body: "\(error)")
                                        }
                                    }
                                })
                            } label: {
                                Label("Symlink", systemImage: "arrow.up.right.circle")
                            }
                        } label: {
                            Label("New...", systemImage: "plus")
                        }
                        
                        Button {
                            showFileImporter.toggle()
                        } label: {
                            Label("Import File", systemImage: "arrow.down.doc")
                        }
                        Divider()
                    }
                    NavigationLink {
                        FileBrowserView(path: URL.documentsDirectory)
                    } label: {
                        Label("Open App Docs", systemImage: "folder")
                    }
                    NavigationLink {
                        List {
                            Section {
                                Picker("List Style", selection: $listStyle) {
                                    Text("Default").tag(1)
                                    Text("Plain").tag(2)
                                    Text("Grouped").tag(3)
                                }
                                Toggle("Hide Dates", isOn: $hideDates)
                            } header: {
                                HeaderLabel(text: "View Options", icon: "eyes")
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
                                HeaderLabel(text: "Text Viewer", icon: "doc.plaintext")
                            }
                        }
                        .navigationTitle("FM Settings")
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis")
                }
                .labelStyle(.iconOnly)
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.item]) { result in
            handleImport(result)
        }
        .refreshable {
            mgr.refreshFiles.toggle()
        }
        .onAppear {
            if shouldGrant {
                let res = bq.grantAccess(atPath: path.path)
                if res.0 {
                    loadFilesFromPath()
                } else {
                    showFailure = true
                    failMsg = "You don't have permission to view this directory."
                }
            } else {
                loadFilesFromPath()
            }
        }
        // I want to talk to the Apple Engineer who thought it would be cool to remove the one-parameter action closure from onChange.
        .onChange(of: searchText) { (newSearch, _) in
            if newSearch.isEmpty {
                dirFiles = unfilteredFiles
            } else {
                dirFiles = unfilteredFiles.filter { $0.name.localizedCaseInsensitiveContains(newSearch) }
            }
        }
        .onChange(of: chosenSort) {
            loadFilesFromPath()
        }
        .onChange(of: filesAscend) {
            loadFilesFromPath()
        }
        .onChange(of: mgr.refreshFiles) {
            loadFilesFromPath()
        }
    }
    
    // MARK: handle files
    private func loadFilesFromPath() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var unsortedFiles: [FileItem] = []
                if isContainer {
                    let paths = fsHandlers.getDirPaths(path.path)
                    for path in paths {
                        unsortedFiles.append(getFileItem(at: URL(fileURLWithPath: path), isContainer: true))
                    }
                } else {
                    let pathFiles = try fm.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .fileSizeKey, .contentModificationDateKey])
                    
                    unsortedFiles = pathFiles.map { fileURL in
                        if path == FSURL.appGroup || path == FSURL.systemData {
                            return getFileItem(at: fileURL, isContainer: true)
                        } else {
                            return getFileItem(at: fileURL)
                        }
                    }
                }
                dirFiles = sortFiles(files: unsortedFiles)
                unfilteredFiles = sortFiles(files: unsortedFiles)
            } catch {
                print("[!] failed to load files from \(path): \(error)")
                showFailure = true
                failMsg = "You may not have permission to view this directory. Check error logs for more detailed info."
            }
            isLoading = false
        }
    }
    
    private func sortFiles(files: [FileItem]) -> [FileItem] {
        var sortedFiles: [FileItem]
        
        switch chosenSort {
        case .system:
            sortedFiles = files
        case .name:
            sortedFiles = files.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .date:
            sortedFiles = files.sorted { $0.modifiedDate > $1.modifiedDate }
        case .type:
            sortedFiles = files.sorted { $0.type.sortOrder < $1.type.sortOrder }
        case .size:
            sortedFiles = files.sorted { $0.size < $1.size }
        }

        sortedFiles = filesAscend ? sortedFiles : sortedFiles.reversed()
        sortedFiles = sortedFiles.sorted { a, b in
            a.hidden && !b.hidden
        }
        return sortedFiles
    }
    
    // MARK: handle import
    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let fileURL):
            do {
                let stopAccess = fileURL.startAccessingSecurityScopedResource()
                defer {
                    if stopAccess {
                        fileURL.stopAccessingSecurityScopedResource()
                    }
                }
                let data = try Data(contentsOf: fileURL)
                
                let newURL = path.appendingPathComponent(fileURL.lastPathComponent)
                try? fm.removeItem(at: newURL)
                
                try data.write(to: newURL)
                mgr.refreshFiles.toggle()
            } catch {
                print("(fm) failed to import file: \(error)")
                Alertinator.shared.alert(title: "Failed to import file!", body: "\(error)")
            }
        case .failure(let error):
            print("(fm) failed to import file: \(error)")
            Alertinator.shared.alert(title: "Failed to import file!", body: "\(error)")
        }
    }
}

extension View {
    @ViewBuilder
    func customListStyle(_ selection: Int) -> some View {
        switch selection {
        case 2: self.listStyle(.inset)
        case 3: self.listStyle(.grouped)
        default: self.listStyle(.insetGrouped)
        }
    }
    
    @ViewBuilder
    func adaptiveListMargin() -> some View {
        if #available(iOS 26.0, *) {
            self.contentMargins(.top, 1)
        }
    }
}
