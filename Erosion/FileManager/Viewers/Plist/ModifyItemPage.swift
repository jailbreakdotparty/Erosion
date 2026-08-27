//
//  ModifyItemPage.swift
//  Filos
//
//  Created by lunginspector on 7/25/26.
//

import SwiftUI
import PartyUI

struct ModifyItemPage: View {
    @EnvironmentObject private var pmgr: PlistManager
    @Environment(\.dismiss) var dismiss
    
    @State var ogItem: PlistItem = PlistItem(key: "", value: "")
    @Binding var item: PlistItem
    @State private var isEditing = false
    
    var body: some View {
        List {
            Section {
                if isEditing {
                    TextField("Key", text: $item.key)
                } else {
                    Text(item.key)
                }
                Picker("Type", selection: $item.type) {
                    ForEach(PlistItemType.allCases, id: \.self) { type in
                        if type != .unknown {
                            Text(type.label).id(type)
                        }
                    }
                }
                .disabled(!isEditing)
            } header: {
                HeaderLabel(text: "Identity", icon: "creditcard")
            }
            
            Section {
                switch item.type {
                case .dict, .array:
                    Button("Add Item") {
                        item.dictVal.insert(PlistItem(key: "New Item", value: ""), at: 0)
                    }
                    .disabled(!isEditing)
                    ForEach($item.dictVal) { $nestItem in
                        ItemRow(item: $nestItem, hierarchy: 0).environmentObject(pmgr)
                            .disabled(isEditing && nestItem.key == "New Item")
                            .swipeActions {
                                if isEditing {
                                    Button(role: .destructive) {
                                        item.dictVal.removeAll { $0.id == nestItem.id }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                    }
                case .data:
                    Text(item.stringVal)
                case .bool:
                    Toggle(item.boolVal.description.capitalized, isOn: $item.boolVal)
                default:
                    TextField(item.type.label, text: $item.stringVal)
                        .disabled(!isEditing)
                }
            } header: {
                if item.type == .dict || item.type == .array {
                    HeaderLabel(text: "Value (\(item.dictVal.count) items)", icon: "character.cursor.ibeam")
                } else {
                    HeaderLabel(text: "Value", icon: "character.cursor.ibeam")
                }
            }
            
            if isEditing {
                Button("Delete Item", role: .destructive) {
                    let res = pmgr.writePlistItems(delItem: item)
                    if !res {
                        Alertinator.shared.alert(title: "Failed to delete plist item!", body: Errors.checkLogs)
                    } else {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("\(item.key)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .listStyle(.grouped)
        .onAppear {
            Task {
                let plistItem = pmgr.plistArray.first(where: { $0.id == item.id }) ?? item
                ogItem = plistItem
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if isEditing {
                    Button {
                        item = ogItem
                        isEditing = false
                    } label: {
                        ToolbarLabel("Cancel", icon: "xmark")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if isEditing {
                    Button(role: .adaptiveConfirm) {
                        let res = pmgr.writePlistItems(newItem: item)
                        if res {
                            Haptic.shared.play(.soft)
                        } else {
                            Alertinator.shared.alert(title: "Failed to write plist items!", body: "Check error logs for more detailed information.")
                            item = ogItem
                        }
                        isEditing = false
                    } label: {
                        ToolbarLabel("Save", icon: "checkmark")
                    }
                } else {
                    if pmgr.isWritable {
                        Button {
                            isEditing = true
                        } label: {
                            ToolbarLabel("Edit", icon: "pencil")
                        }
                    }
                }
            }
        }
    }
}
