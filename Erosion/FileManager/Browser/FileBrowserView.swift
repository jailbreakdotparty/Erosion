//
//  FileBrowserView.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/12/26.
//

import SwiftUI

import QuickLook
import Combine

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

enum FileBrowserState {
    case loading, loaded, noPerms, noFiles, unknownError
    
    var description: String {
        switch self {
        case .noFiles: return "This directory is empty."
        case .noPerms: return "You don't have permission to view the files in this directory."
        case .unknownError: return "Unknown error."
        default: return ""
        }
    }
    
    var symbol: String {
        switch self {
        case .noFiles: return "questionmark.folder"
        case .noPerms: return "externaldrive.badge.xmark"
        case .unknownError: return "exclamationmark.triangle"
        default: return ""
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
    @AppStorage("maxInode") var maxInode = 7500000
    @AppStorage("chosenSort") var chosenSort: FileSortMode = .system
    @AppStorage("filesAscend") var filesAscend = true
    @AppStorage("listStyle") var listStyle = 1
    @AppStorage("hideDates") var hideDates = false
    @AppStorage("textViewerSize") var textViewerSize = 10
    @AppStorage("useMonospaced") var useMonospaced = true
    @AppStorage("autoRefresh") var autoRefresh = true
    
    @State private var showFileImporter = false
    @State private var currentState = FileBrowserState.loading
    @State private var localizedError = ""
    @State private var isLoadingInBackground = false
    @State private var showSettingsSheet = false
    
    var body: some View {
        Group {
            if currentState == .loading {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.25)
                    Text("Loading Files...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else if currentState == .loaded {
                List {
                    ForEach(dirFiles) { file in
                        if file.type == .folder {
                            FolderRow(file: file, shouldGrant: shouldGrant || isContainer, isContainer: isContainer)
                        } else {
                            FileRow(file: file)
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: currentState.symbol)
                        .font(.largeTitle)
                    if currentState == .noFiles {
                        Text(currentState.description)
                    } else {
                        VStack {
                            Text("Failed to load files from path!")
                            Text(currentState == .unknownError ? localizedError : currentState.description)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(path.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .customListStyle(listStyle)
        .adaptiveListMargin()
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isLoadingInBackground {
                    ProgressView()
                }
            }
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
                                            print("(fm) failed to create file: \(error.localizedDescription)")
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
                                            print("(fm) failed to create plist: \(error.localizedDescription)")
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
                                            print("(fm) failed to create folder: \(error.localizedDescription)")
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
                                            print("(fm) failed to create symlink: \(error.localizedDescription)")
                                            Alertinator.shared.alert(title: "Failed to create symlink!", body: "\(error.localizedDescription)")
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
                    Button {
                        showSettingsSheet = true
                    } label: {
                        Label("Settings", systemImage: "gear")
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
            if !mgr.storedFiles.isEmpty && mgr.storedURL == path {
                dirFiles = sortFiles(files: mgr.storedFiles)
                unfilteredFiles = sortFiles(files: mgr.storedFiles)
            } else {
                if shouldGrant {
                    let res = wq.grantAccess(path: path.path)
                    if res.0 {
                        loadFilesFromPath()
                    } else {
                        currentState = .noPerms
                    }
                } else {
                    loadFilesFromPath()
                }
            }
        }
        // I want to talk to the Apple Engineer who thought it would be cool to remove the one-parameter action closure from onChange.
        .onChange(of: searchText) { (newSearch, _) in
            dirFiles = unfilteredFiles.filter { $0.name.localizedCaseInsensitiveContains(newSearch) }
        }
        .modifier(KeyboardDismissObserver() {
            dirFiles = unfilteredFiles
        })
        .onChange(of: chosenSort) {
            loadFilesFromPath()
        }
        .onChange(of: filesAscend) {
            loadFilesFromPath()
        }
        .onChange(of: mgr.refreshFiles) {
            loadFilesFromPath()
        }
        .sheet(isPresented: $showSettingsSheet) {
            FMSettings()
        }
    }
    
    // MARK: handle files
    /*
     refactor and caching idea is basically just this:
     - any file/folder that doesn't need pathleak: no caching needed! just grant access.
     - container domains that need pathleak:
        - if it's not already been loaded or saved, it will load the files and save them into appstorage.
        - if something has been saved, it will present those containers and then load new ones. it will then append whatever hasn't been added to the array (filter out based on path) and fetch new label names, and the new array it loaded will be saved to appstorage.
        - appstorage variable: savedFiles_path :thumbs_up:
     */
    
    private func loadFilesFromPath() {
        if isContainer {
            loadFilesForContainer()
        } else {
            loadFiles()
        }
    }
    
    private func loadFiles() {
        currentState = .loading
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var unsortedFiles: [FileItem] = []
                let pathFiles = try fm.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .fileSizeKey, .contentModificationDateKey])
                
                unsortedFiles = pathFiles.map { fileURL in
                    return getFileItem(at: fileURL)
                }
                dirFiles = sortFiles(files: unsortedFiles)
                unfilteredFiles = sortFiles(files: unsortedFiles)
                if dirFiles.isEmpty {
                    currentState = .noFiles
                } else {
                    currentState = .loaded
                }
            } catch {
                let nserror = error as NSError
                print("[!] failed to load files from \(path.path): \(nserror.localizedDescription) (code \(nserror.code))")
                if nserror.code == NSFileReadNoPermissionError {
                    currentState = .noPerms
                } else {
                    localizedError = nserror.localizedDescription
                    currentState = .unknownError
                }
            }
        }
    }
    
    private func loadFilesForContainer() {
        currentState = .loading
        DispatchQueue.global(qos: .userInitiated).async {
            // load what's already been saved for container files (if it exists)
            if let saved = UserDefaults.standard.codable([FileItem].self, forKey: "savedFiles_\(path.path)") {
                dirFiles = sortFiles(files: saved)
                unfilteredFiles = sortFiles(files: saved)
                currentState = .loaded
                if !autoRefresh { return }
                isLoadingInBackground = true
            }
            // then fetch with pathleak
            var unsortedFiles: [FileItem] = []
            let paths = fsHandlers.getDirPaths(path.path, maxInode: maxInode)
            for path in paths {
                unsortedFiles.append(getFileItem(at: URL(fileURLWithPath: path)))
            }
            UserDefaults.standard.setCodable(unsortedFiles, forKey: "savedFiles_\(path.path)")
            // if it's empty then write what's already been changed to the ui, else just update the files already showing up in the ui
            if dirFiles.isEmpty {
                dirFiles = sortFiles(files: unsortedFiles)
                unfilteredFiles = sortFiles(files: unsortedFiles)
            } else {
                // remove the files that no longer exist in the unsortedFiles array
                let unsortedFileURLs = unsortedFiles.map { $0.fileURL }
                dirFiles.removeAll { !unsortedFileURLs.contains($0.fileURL) }
                unsortedFiles.removeAll { !unsortedFileURLs.contains($0.fileURL) }
                // add any files that do suddenly exist
                let existingFileURLs = dirFiles.map { $0.fileURL }
                let newFiles = unsortedFiles.filter( { !existingFileURLs.contains($0.fileURL) })
                dirFiles = sortFiles(files: dirFiles + newFiles)
                unsortedFiles = sortFiles(files: dirFiles + newFiles)
            }
            if dirFiles.isEmpty {
                currentState = .noFiles
            } else {
                currentState = .loaded
            }
            isLoadingInBackground = false
        }
    }
    
    /*
    private func loadFilesFromPath() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var unsortedFiles: [FileItem] = []
                if isContainer {
                    if let saved = UserDefaults.standard.value(forKey: "savedFiles_\(path.path)") as? [FileItem] {
                        
                    }
                    let paths = fsHandlers.getDirPaths(path.path, maxInode: maxInode)
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
                if isContainer {
                    mgr.storedFiles = unsortedFiles
                    mgr.storedURL = path
                }
                hasLoaded = true
            } catch {
                print("(fm) failed to load files from \(path): \(error.localizedDescription)")
                showFailure = true
                failMsg = "You may not have permission to view this directory. Check error logs for more detailed info."
            }
            isLoading = false
        }
    }
     */
    
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
                print("(fm) failed to import file: \(error.localizedDescription)")
                Alertinator.shared.alert(title: "Failed to import file!", body: "\(error.localizedDescription)")
            }
        case .failure(let error):
            print("(fm) failed to import file: \(error.localizedDescription)")
            Alertinator.shared.alert(title: "Failed to import file!", body: "\(error.localizedDescription)")
        }
    }
}

// MARK: user interface
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

struct KeyboardDismissObserver: ViewModifier {
    var action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(Publishers.keyboardDismissed) { _ in
                action()
            }
    }
}

extension Publishers {
    static var keyboardDismissed: AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardDidHideNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
