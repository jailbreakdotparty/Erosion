//
//  GestaltInfoSheet.swift
//  Erosion
//
//  Created by lunginspector on 8/20/26.
//

import SwiftUI
import PartyUI

struct InfoSheetCell: View {
    var icon: String
    var title: String
    var context: String
    
    public var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(width: 28, height: 28, alignment: .center)
                Text(title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.accentColor)
            .font(.system(.title3, weight: .medium))
            Text(context)
                .font(.callout)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InfoSheet<CellContent: View, ButtonContent: View>: View {
    var title: String
    @ViewBuilder var cellContent: CellContent
    @ViewBuilder var buttonContent: ButtonContent
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(.title, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 30)
            Spacer()
            VStack(alignment: .leading, spacing: 30) {
                cellContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            Spacer()
            VStack {
                buttonContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        }
    }
}
