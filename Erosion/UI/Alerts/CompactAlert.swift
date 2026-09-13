//
//  CompactAlert.swift
//  PartyUI
//
//  Created by lunginspector on 4/5/26.
//

import SwiftUI

struct CompactAlert: View {
    var title = ""
    var symbol = ""
    var text: String
    var color = Color.accentColor
    
    public var body: some View {
        HStack(spacing: 10) {
            if !symbol.isEmpty {
                Image(systemName: symbol)
                    .imageScale(.large)
            }
            VStack(alignment: .leading) {
                if !title.isEmpty {
                    Text(title)
                        .fontWeight(.medium)
                }
                Text(text)
                    .font(!title.isEmpty ? .subheadline : .body)
            }
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.2), in: .rect(cornerRadius: cornerRad.platter))
    }
}
