//
//  CustomKeyView.swift
//  Erosion
//
//  Created by lunginspector on 9/8/26.
//

import SwiftUI


struct MGCustomKey: Identifiable, Codable, Equatable {
    var id: String { key }
    let key: String
    var value: Int
    var isOn = false
}

struct CustomKeyView: View {
    @AppStorage("mgCustKeyArray") private var customKeys = [MGCustomKey]()
    @State private var cstkKey = ""
    @State private var cstkValue: Int?
    @State private var itemToEdit: MGCustomKey?
    
    var body: some View {
        List {
            Section {
                TextField("Key", text: $cstkKey)
                TextField("Value", value: $cstkValue, format: .number)
                    .keyboardType(.numberPad)
                Button("Add Key") {
                    if cstkKey.isEmpty || cstkValue == nil {
                        Alertinator.shared.alert(title: "This seems like an invaild key!", body: "Try putting something inside of this field, and then try again!")
                    } else if let _ = customKeys.firstIndex(where: { $0.key == cstkKey }) {
                        Alertinator.shared.alert(title: "This key has already been added!", body: "Scroll to that key if you'd like to modify it.")
                    } else {
                        customKeys.append(MGCustomKey(key: cstkKey, value: cstkValue ?? 0))
                    }
                }
            } header: {
                HeaderLabel( "Add Keys", symbol: "plus")
            }
            
            Section {
                ForEach(customKeys) { item in
                    Toggle(isOn: mgIsOnBinding(for: item)) {
                        Button(item.key) {
                            itemToEdit = item
                        }
                        .foregroundStyle(Color(.label))
                    }
                }
                // new thing to learn: ondelete. way better for having a delete button actually as it'll add it to each cell automatically.
                .onDelete { indexSet in
                    customKeys.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationTitle("Custom Keys")
        .scrollDismissesKeyboard(.interactively)
        .sheet(item: $itemToEdit) { item in
            EditorPane(item: item)
                .presentationDetents([.fraction(0.3)])
        }
    }
    
    // i hate this as a solution, but it seems like there's a long-standing bug in swiftui where the whole app will crash if i drop all items from an array that uses a direct binding with toggles. really stupid, i know, but that's sorta the way things are. gotta love swiftui...
    // -lunginspector 8/6/26
    private func mgIsOnBinding(for item: MGCustomKey) -> Binding<Bool> {
        Binding(
            get: { customKeys.first(where: { $0.id == item.id })?.isOn ?? false },
            set: { newValue in
                if let index = customKeys.firstIndex(where: { $0.id == item.id }) {
                    customKeys[index].isOn = newValue
                }
            }
        )
    }
    
    private struct EditorPane: View {
        @State var item: MGCustomKey
        @Environment(\.dismiss) var dismiss
        @AppStorage("mgCustKeyArray") var customKeys: [MGCustomKey] = []
        
        var body: some View {
            NavigationStack {
                VStack {
                    Text(item.key)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .modifier(TextFieldBackground())
                    TextField("Value", value: $item.value, format: .number)
                        .modifier(TextFieldBackground())
                }
                .padding(.horizontal)
                .navigationTitle("Modify Key")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Close", systemImage: "xmark")
                                .labelStyle(.iconOnly)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .adaptiveConfirm) {
                            if let index = customKeys.firstIndex(where: { $0.key == item.key }) {
                                customKeys[index] = item
                            }
                            dismiss()
                        } label: {
                            Label("Confirm", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
    }
}
