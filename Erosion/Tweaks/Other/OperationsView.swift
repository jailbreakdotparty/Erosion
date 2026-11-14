//
//  OperationsView.swift
//  Erosion
//
//  Created by lunginspector on 8/17/26.
//

import SwiftUI
import UniformTypeIdentifiers


struct OperationsView: View {
    @State private var path = ""
    @State private var isAcc = false
    @State private var showImporter = false
    
    @State private var imprtName = ""
    @State private var imprtData = Data()
    
    var body: some View {
        List {
            Section {
                TextField("Path", text: $path)
                    .disabled(isAcc)
                HStack {
                    Button("Grant Access") {
                        let res = wq.grantAccess(path: path)
                        if !res.0 {
                            Alertinator.shared.alert(title: "Failed to get access to \(path)!", body: "\(res.1): \(res.2)")
                        } else {
                            isAcc = true
                        }
                    }
                    .disabled(isAcc)
                    if isAcc {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Access Granted")
                        }
                        .foregroundStyle(.green)
                    }
                }
                if isAcc {
                    Button("Change Path", role: .destructive) {
                        isAcc = false
                        imprtName = ""
                        imprtData = Data()
                    }
                    
                    Button("Export File") {
                        presentShareSheet(with: URL(fileURLWithPath: path))
                    }
                }
            } header: {
                HeaderLabel("Target", symbol: "dot.scope")
            }
            
            Section {
                HStack {
                    Button("Import File") {
                        showImporter = true
                    }
                    .disabled(!imprtData.isEmpty)
                    if !imprtName.isEmpty {
                        Spacer()
                        Text(imprtName)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                
                Button("Overwrite File") {
                    do {
                        let targetURL = URL(fileURLWithPath: path)
                        try imprtData.write(to: targetURL)
                        print("(ov) successfully overwrote file: \(targetURL.path) (\(imprtData.count))")
                        Haptic.shared.play(.soft)
                    } catch {
                        print("(ov) failed to overwrite: \(error.localizedDescription)")
                        Alertinator.shared.alert(title: "Failed to overwrite file!", body: "Make sure that your paths are correct and that you have access. Check error logs for more detailed information.")
                    }
                }
                .disabled(imprtData.isEmpty)
                
                Button("Move File") {
                    do {
                        let targetURL = URL(fileURLWithPath: path)
                        try imprtData.write(to: targetURL)
                        print("(ov) successfully moved file: \(imprtName) -> \(targetURL.path)")
                        Haptic.shared.play(.soft)
                    } catch {
                        print("(ov) failed to move: \(error.localizedDescription)")
                        Alertinator.shared.alert(title: "Failed to move file!", body: "Make sure that your paths are correct and that you have access. Check error logs for more detailed information.")
                    }
                }
                .disabled(imprtData.isEmpty)
                
                Button("Delete File", role: .destructive) {
                    do {
                        let targetURL = URL(fileURLWithPath: path)
                        try fm.removeItem(at: targetURL)
                        print("(ov) successfully deleted file: \(targetURL.path)")
                        Haptic.shared.play(.heavy)
                    } catch {
                        print("(ov) failed to delete: \(error.localizedDescription)")
                        Alertinator.shared.alert(title: "Failed to delete file!", body: "Make sure that your paths are correct and that you have access. Check error logs for more detailed information.")
                    }
                }
                .disabled(imprtData.isEmpty)
            } header: {
                HeaderLabel("Operations", symbol: "wrench.and.screwdriver")
            }
        }
        .navigationTitle("File Operations")
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
            handleImport(result)
        }
    }
    
    func handleImport(_ res: Result<URL, Error>) {
        switch res {
        case .success(let recURL):
            do {
                let stopAccess = recURL.startAccessingSecurityScopedResource()
                defer {
                    if stopAccess {
                        recURL.stopAccessingSecurityScopedResource()
                    }
                }
                
                imprtData = try Data(contentsOf: recURL)
                imprtName = recURL.lastPathComponent
            } catch {
                print("(ov) failed to import file: \(error.localizedDescription)")
                Alertinator.shared.alert(title: "Failed to import file!", body: "This file is likely invaild, corrupted, or inaccessible. Please try a different overwrite file.")
            }
        case .failure(let error):
            print("(ov) failed to import file: \(error.localizedDescription)")
            Alertinator.shared.alert(title: "Failed to import file!", body: "This file is likely invaild, corrupted, or inaccessible. Please try a different overwrite file.")
        }
    }
}
