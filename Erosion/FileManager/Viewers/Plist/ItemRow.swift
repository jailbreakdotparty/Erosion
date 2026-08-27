//
//  ItemRow.swift
//  Filos
//
//  Created by lunginspector on 7/25/26.
//

import SwiftUI

struct ItemRow: View {
    @EnvironmentObject private var pmgr: PlistManager
    @Binding var item: PlistItem
    let hierarchy: Int
    
    var body: some View {
        Group {
            if item.type == .dict || item.type == .array || item.type == .data {
                HStack {
                    Button {
                        item.isExpanded.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.down")
                                .font(.body.weight(.semibold))
                                .imageScale(.small)
                                .rotationEffect(.degrees(item.isExpanded ? 0 : -90))
                                .animation(.easeInOut(duration: 0.2), value: item.isExpanded)
                            Text(item.key)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    if item.type != .data {
                        Text("\(item.type.label) (\(item.dictVal.count.description))")
                    } else {
                        Text(item.type.label)
                    }
                    Image(systemName: "info.circle")
                        .overlay {
                            NavigationLink(destination: ModifyItemPage(item: $item).environmentObject(pmgr)) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                }
                .listRowBackground(Color(uiColor: .hierarchyLevelColor(hierarchy)))
                // dictionary inception time
                if item.isExpanded {
                    if item.type == .data {
                        Text(item.stringVal)
                            .font(.system(size: 12, design: .monospaced))
                            .lineLimit(12)
                            .listRowBackground(Color(uiColor: .hierarchyLevelColor(hierarchy + 1)))
                            .overlay {
                                NavigationLink(destination: ModifyItemPage(item: $item).environmentObject(pmgr)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                    } else {
                        ForEach($item.dictVal) { $item in
                            ItemRow(item: $item, hierarchy: hierarchy + 1).environmentObject(pmgr)
                                .environmentObject(pmgr)
                        }
                    }
                }
            } else {
                NavigationLink(destination: ModifyItemPage(item: $item).environmentObject(pmgr)) {
                    HStack {
                        Text(item.key)
                            .lineLimit(1)
                        Spacer()
                        Text(item.stringVal)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowBackground(Color(uiColor: .hierarchyLevelColor(hierarchy)))
            }
        }
        .contextMenu {
            Menu {
                Button("Key") {
                    UIPasteboard.general.string = item.key
                }
                
                Button("Value") {
                    UIPasteboard.general.string = item.stringVal
                }
            } label: {
                Label("Copy...", systemImage: "doc.on.doc")
            }
        }
    }
}
