//
//  OperationsView.swift
//  Erosion
//
//  Created by lunginspector on 8/17/26.
//

import SwiftUI
import UniformTypeIdentifiers
import PartyUI

let bq = BadQuery()

struct OperationsView: View {
    @State private var directory = ""
    @State private var fileName = ""
    @State private var isAcc = false
    @State private var showImporter = false
    
    @State private var imprtName = ""
    @State private var imprtData = Data()
    
    var body: some View {
        List {
            Section {
                TextField("Directory", text: $directory)
                    .disabled(isAcc)
                TextField("File Name", text: $fileName)
                    .disabled(isAcc)
                HStack {
                    Button("Grant Access") {
                        let res = bq.grantAccess(atPath: directory, toFileName: fileName)
                        if !res.0 {
                            Alertinator.shared.alert(title: "Failed to get access to target file!", body: "Error \(res.1): \(res.2)")
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
                        let fileDir = "\(directory)/\(fileName)"
                        presentShareSheet(with: URL(fileURLWithPath: fileDir))
                    }
                }
            } header: {
                HeaderLabel(text: "Target", icon: "dot.scope")
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
                        let targetURL = URL(fileURLWithPath: "\(directory)/\(fileName)")
                        try imprtData.write(to: targetURL)
                        print("(ov) successfully overwrote file: \(targetURL.path) (\(imprtData.count))")
                        Haptic.shared.play(.soft)
                    } catch {
                        print("(ov) failed to overwrite: \(error)")
                        Alertinator.shared.alert(title: "Failed to overwrite file!", body: "Make sure that your paths are correct and that you have access. Check error logs for more detailed information.")
                    }
                }
                .disabled(imprtData.isEmpty)
                
                Button("Move File") {
                    do {
                        let targetURL = URL(fileURLWithPath: "\(directory)").appendingPathComponent(imprtName)
                        try imprtData.write(to: targetURL)
                        print("(ov) successfully moved file: \(imprtName) -> \(targetURL.path)")
                        Haptic.shared.play(.soft)
                    } catch {
                        print("(ov) failed to move: \(error)")
                        Alertinator.shared.alert(title: "Failed to move file!", body: "Make sure that your paths are correct and that you have access. Check error logs for more detailed information.")
                    }
                }
                .disabled(imprtData.isEmpty)
                
                Button("Delete File", role: .destructive) {
                    do {
                        let targetURL = URL(fileURLWithPath: "\(directory)/\(fileName)")
                        try fm.removeItem(at: targetURL)
                        print("(ov) successfully deleted file: \(targetURL.path)")
                        Haptic.shared.play(.heavy)
                    } catch {
                        print("(ov) failed to delete: \(error)")
                        Alertinator.shared.alert(title: "Failed to delete file!", body: "Make sure that your paths are correct and that you have access. Check error logs for more detailed information.")
                    }
                }
                .disabled(imprtData.isEmpty)
            } header: {
                HeaderLabel(text: "Operations", icon: "wrench.and.screwdriver")
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
                print("(ov) failed to import file: \(error)")
                Alertinator.shared.alert(title: "Failed to import file!", body: "This file is likely invaild, corrupted, or inaccessible. Please try a different overwrite file.")
            }
        case .failure(let error):
            print("(ov) failed to import file: \(error)")
            Alertinator.shared.alert(title: "Failed to import file!", body: "This file is likely invaild, corrupted, or inaccessible. Please try a different overwrite file.")
        }
    }
}
