//
//  KeypadView.swift
//  Erosion
//
//  Created by lunginspector on 8/28/26.
//

import SwiftUI
import PartyUI
import PhotosUI

struct KeypadView: View {
    @StateObject private var kpMgr = KeypadManager.shared
    @AppStorage("mpContainerPath") private var mpContainerPath = ""
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    @State private var size: KPSize = KPSize.defSize
    @State private var custW = 0
    @State private var custH = 0
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 2) {
                Text("Key Size")
                Picker("", selection: $size) {
                    ForEach(KPSize.allCases, id: \.self) { kpSize in
                        Text(kpSize.label).tag(kpSize)
                    }
                }
                .onChange(of: size) { _, newSize in
                    if newSize == KPSize.custom {
                        Alertinator.shared.prompt(title: "What would you like the new width to be?", completion: { res1 in
                            if let wStr = res1 {
                                custW = Int(wStr) ?? 0
                                Alertinator.shared.prompt(title: "What would you like the new height to be?", completion: { res2 in
                                    if let hStr = res2 {
                                        custH = Int(hStr) ?? 0
                                        kpMgr.changeSizeOfKeypads(size: size, custW: custW, custH: custH)
                                    }
                                })
                            }
                        })
                    } else {
                        kpMgr.changeSizeOfKeypads(size: newSize)
                    }
                }
            }
            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                ForEach($kpMgr.mpKeypad) { $item in
                    KeyItem(size: $size, kpID: item.kpID, imgData: $item.imgData)
                        .environmentObject(kpMgr)
                }
            }
            Button {
                kpMgr.applyKeypadItems()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(KeypadButtonStyle(isConfirm: true))
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 30)
        .navigationTitle("Dialer Themer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        kpMgr.mpKeypad = emptyKeypadArray
                    } label: {
                        Label("Clear Keys", systemImage: "trash")
                    }
                    Button(role: .destructive) {
                        Alertinator.shared.alert(title: "Are you sure you'd like to reset your set keys?", body: KPMsg.resetWarn, actionLabel: "Confirm", action: {
                            let res = kpMgr.resetKeypadItems()
                            if res {
                                kpMgr.mpKeypad = emptyKeypadArray
                                Alertinator.shared.alert(title: "Successfully reset dialer keys!", body: KPMsg.applyComp)
                            } else {
                                Alertinator.shared.alert(title: "Failed to reset dialer keys!", body: AppMsg.opFailed)
                            }
                        })
                    } label: {
                        Label("Reset Keys", systemImage: "xmark")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                }
            }
            ToolbarSpacer(placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button("Import") {
                    
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
            kpMgr.getCurrentKeypads(size: size, isOnAppear: true)
        }
    }
    
    private struct KeyItem: View {
        @EnvironmentObject private var kpMgr: KeypadManager
        @Binding var size: KPSize
        @State var kpID: KeypadID
        @Binding var imgData: Data
        @State private var didFinish = false
        @State private var image: UIImage?
        @State private var showPicker = false
        
        var body: some View {
            Button {
                showPicker = true
            } label: {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: CGFloat(Float(img.size.width)/3), height: CGFloat(Float(img.size.height)/3))
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
                ImagePickerView(image: $image, updateView: $didFinish)
            }
            .onChange(of: didFinish) {
                // need a delay unless you want a lovely race condition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let img = image {
                        guard let data = img.pngData() else { return }
                        let imgData = {
                            switch size {
                            case .defSize: return kpMgr.resizeAndRet(withData: data, isDefault: true)
                            case .custom: return kpMgr.resizeAndRet(withData: data, customSize: CGSize(width: Int(img.size.width), height: Int(img.size.height)))
                            default: return kpMgr.resizeAndRet(withData: data, newSize: size.float)
                            }
                        }()
                        kpMgr.updateKeypadItem(forID: kpID, withData: imgData, ogData: imgData)
                    }
                }
            }
            .onAppear {
                if let img = UIImage(data: imgData) {
                    image = img
                }
            }
            .onChange(of: imgData) {
                if let img = UIImage(data: imgData) {
                    image = img
                }
            }
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
