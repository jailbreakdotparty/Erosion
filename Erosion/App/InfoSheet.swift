//
//  InfoSheet.swift
//  Erosion
//
//  Created by lunginspector on 8/20/26.
//

import SwiftUI
import PartyUI

struct InfoSheet<CellContent: View, ButtonContent: View>: View {
    var title: String
    @ViewBuilder var cell: CellContent
    @ViewBuilder var button: ButtonContent
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            ScrollView {
                VStack(spacing: 15) {
                    cell
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 25)
        .safeAreaInset(edge: .bottom) {
            button
                .modifier(OverlayBackground())
        }
    }
}

struct InfoSheetCell: View {
    var title: String
    var icon: String
    var context: String
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .frame(width: 24, height: 22, alignment: .center)
                Text(title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.body.weight(.medium))
            .foregroundStyle(Color.accentColor)
            
            Text(context)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

struct ConfirmButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 19.0, *) {
            configuration.label
                .buttonStyle(.plain)
                .foregroundStyle(isEnabled ? Color(.label) : .gray)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .contentShape(.capsule)
                .glassEffect(.regular.interactive().tint(isEnabled ? .blue : Color(.systemGray)), in: .capsule)
        } else {
            configuration.label
                .buttonStyle(.plain)
                .foregroundStyle(isEnabled ? Color(.label) : .gray)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .contentShape(.capsule)
                .background(isEnabled ? Color.accentColor : Color(.systemGray), in: .capsule)
        }
    }
}
