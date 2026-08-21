//
//  ButtonStyles.swift
//  Erosion
//
//  Created by lunginspector on 8/20/26.
//

import SwiftUI

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
                .glassEffect(.regular.interactive().tint(isEnabled ? .blue : Color.clear), in: .capsule)
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

struct ActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 19.0, *) {
            configuration.label
                .buttonStyle(.plain)
                .foregroundStyle(isEnabled ? Color(.label) : .gray)
                .fontWeight(.medium)
                .padding()
                .contentShape(.capsule)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            configuration.label
                .buttonStyle(.plain)
                .foregroundStyle(isEnabled ? Color(.label) : .gray)
                .fontWeight(.medium)
                .padding()
                .contentShape(.capsule)
                .background(isEnabled ? Color.accentColor : Color(.systemGray), in: .capsule)
        }
    }
}
