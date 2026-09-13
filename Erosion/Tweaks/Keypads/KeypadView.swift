//
//  KeypadView.swift
//  Erosion
//
//  Created by lunginspector on 8/28/26.
//

import SwiftUI

import PhotosUI

struct KeypadView: View {
    @StateObject private var kpMgr = KeypadManager.shared
    @AppStorage("showTips") var showTips = true
    @AppStorage("mpContainerPath") private var mpContainerPath = ""
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    @State private var size: KPSize = KPSize.defSize
    @State private var showSizeAlert = false
    @State private var custW = 0
    @State private var custH = 0
    @State private var showFileImporter = false
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                ForEach($kpMgr.mpKeypad) { $item in
                    KeyItem(size: $size, kpID: item.kpID, imgData: $item.imgData)
                        .environmentObject(kpMgr)
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: 2) {
                    Text("Key Size")
                    Picker("", selection: $size) {
                        ForEach(KPSize.allCases, id: \.self) { kpSize in
                            Text(kpSize.label + (kpSize == .custom ? " (\(custW)x\(custH))" : "")).tag(kpSize)
                        }
                    }
                    .alert("What would you like the custom size to be?", isPresented: $showSizeAlert) {
                        TextField("Width", value: $custW, format: .number)
                            .keyboardType(.numberPad)
                        TextField("Height", value: $custH, format: .number)
                            .keyboardType(.numberPad)
                        Button("Cancel", role: .cancel) {
                            size = .defSize
                        }
                        Button("Set") {
                            kpMgr.changeSizeOfKeypads(size: size, custW: custW, custH: custH)
                        }
                    }
                    .onChange(of: size) { _, newSize in
                        if newSize != KPSize.custom {
                            kpMgr.changeSizeOfKeypads(size: newSize)
                        } else {
                            showSizeAlert.toggle()
                        }
                    }
                }
                .padding(6)
                .background(Color(.systemBackground), in: .rect(cornerRadius: cornerRad.component))
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    let res = kpMgr.applyKeypadItems()
                    if res {
                        if showTips {
                            Alertinator.shared.alert(title: "Successfully applied custom keypads!", body: KPMsg.applyComp, actionLabel: "Open Phone", action: {
                                openApp(withBID: SysBID.phone)
                            })
                        } else {
                            Haptic.shared.play(.soft)
                        }
                    } else {
                        Alertinator.shared.alert(title: "Failed to apply custom keypads!", body: AppMsg.opFailed)
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(KeypadButtonStyle(isConfirm: true))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
            }
        }
        .navigationTitle(isPad() ? "" : "Dialer Themer")
        .frame(maxWidth: 325)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        kpMgr.maskKeysIntoCircle(size: size, custW: custW, custH: custH)
                    } label: {
                        Label("Mask Keys", systemImage: "circle")
                    }
                    Button {
                        size = .defSize
                        kpMgr.getCurrentKeypads()
                    } label: {
                        Label("Get Current Keys", systemImage: "externaldrive")
                    }
                    Button {
                        openApp(withBID: SysBID.phone)
                    } label: {
                        Label("Open Phone", systemImage: "arrow.up.right.square")
                    }
                    Divider()
                    Button {
                        size = .defSize
                        kpMgr.clearKeypads()
                    } label: {
                        Label("Clear Keys", systemImage: "xmark")
                    }
                    Button(role: .destructive) {
                        Alertinator.shared.alert(title: "Are you sure you'd like to reset your set keys?", body: KPMsg.resetWarn, actionLabel: "Confirm", action: {
                            let res = kpMgr.resetKeypadItems()
                            if res {
                                kpMgr.mpKeypad = emptyKeypadArray
                                kpMgr.getCurrentKeypads()
                                Alertinator.shared.alert(title: "Successfully reset dialer keys!", body: KPMsg.applyComp)
                            } else {
                                Alertinator.shared.alert(title: "Failed to reset dialer keys!", body: AppMsg.opFailed)
                            }
                        })
                    } label: {
                        Label("Reset Keys", systemImage: "trash")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                }
            }
            ToolbarSpacer(placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button("Import") {
                    showFileImporter = true
                }
            }
        }
        .onAppear {
            if mpContainerPath.isEmpty {
                mpContainerPath = fsHandlers.getContainerPath(forMatch: "com.apple.mobilephone")
            }
            if !fm.isReadableFile(atPath: mpContainerPath) {
                let _ = bq.grantAccess(atPath: mpContainerPath)
            }
            kpMgr.getCurrentKeypads(size: size, saveOgData: true)
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.item]) { result in
            handleImport(result)
        }
    }
    
    private struct KeyItem: View {
        @EnvironmentObject private var kpMgr: KeypadManager
        @Binding var size: KPSize
        @State var kpID: KeypadID
        @Binding var imgData: Data
        @State private var showPicker = false
        
        var body: some View {
            Button {
                showPicker = true
            } label: {
                if let img = UIImage(data: imgData) {
                    let denoVal: Float = isPad() ? 2.1 : 3.0
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: CGFloat(Float(img.size.width)/denoVal), height: CGFloat(Float(img.size.height)/denoVal))
                        .background {
                            Circle()
                                .fill(Color.clear)
                                .glassEffect(.clear, in: .circle)
                                .frame(width: 78, height: 78)
                        }
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .frame(width: 78, height: 78)
                        .foregroundStyle(Color(.label))
                        .fontWeight(.medium)
                        .glassEffect(.clear.interactive(), in: .circle)
                }
            }
            .frame(width: 80, height: 80)
            .sheet(isPresented: $showPicker) {
                ImagePickerView() { data in
                    imgData = data
                    guard let img = UIImage(data: imgData) else { return }
                    let imgData = {
                        switch size {
                        case .defSize: return kpMgr.resizeAndRet(withData: imgData, isDefault: true)
                        case .custom: return kpMgr.resizeAndRet(withData: imgData, customSize: CGSize(width: Int(img.size.width), height: Int(img.size.height)))
                        default: return kpMgr.resizeAndRet(withData: imgData, newSize: size.float)
                        }
                    }()
                    kpMgr.updateKeypadItem(forID: kpID, withData: imgData, ogData: imgData)
                }
            }
        }
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
                let res = kpMgr.importTheme(fromURL: fileURL)
                if res {
                    Haptic.shared.play(.soft)
                } else {
                    throw "failed to import theme!"
                }
            } catch {
                print("(kp) failed to import theme: \(error)")
                Alertinator.shared.alert(title: "Failed to import file!", body: AppMsg.opFailed)
            }
        case .failure(let error):
            print("(fm) failed to import file: \(error)")
            Alertinator.shared.alert(title: "Failed to import file!", body: "\(error)")
        }
    }
    
}

// MARK: UI
struct KeypadButtonStyle: ButtonStyle {
    var isConfirm = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24))
            .frame(width: 75, height: 75)
            .foregroundStyle(Color(.label))
            .fontWeight(.medium)
            .glassEffect(.clear.tint(isConfirm ? Color.accentColor : Color.clear).interactive(), in: .circle)
    }
}
