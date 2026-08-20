//
//  LogView.swift
//  dirtyZero
//
//  Created by lunginspector on 4/17/26.
//

import SwiftUI
import PartyUI

struct LogView: View {
    @StateObject private var mgr = ErosionManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    Text(mgr.logOutput)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .multilineTextAlignment(.leading)
                    Spacer()
                        .id(0)
                }
                .contextMenu {
                    Button {
                        Haptic.shared.play(.soft)
                        UIPasteboard.general.string = mgr.logOutput
                    } label: {
                        Label("Copy Output", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        do {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM-dd-yyyy-HHmmss"
                            let date = formatter.string(from: Date())
                            
                            let tempURL = URL.temporaryDirectory.appendingPathComponent("Erosion-Log-\(date)").appendingPathExtension("txt")
                            guard let data = mgr.logOutput.data(using: .utf8) else {
                                throw "failed to create data from log string"
                            }
                            
                            try data.write(to: tempURL)
                            presentShareSheet(with: tempURL)
                        } catch {
                            print("[!] failed to export logs: \(error)")
                        }
                    } label: {
                        Label("Export Logs", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
