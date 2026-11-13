//
//  PlainAlert.swift
//  PartyUI
//
//  Created by lunginspector on 4/21/26.
//

import SwiftUI

struct PlainAlert: View {
    var title = ""
    var symbol = ""
    var text: String
    var color = Color(.label)
    
    var body: some View {
        HStack(spacing: 10) {
            if !symbol.isEmpty {
                Image(systemName: symbol)
                    .foregroundStyle(color)
                    .imageScale(.large)
            }
            VStack(alignment: .leading) {
                if !title.isEmpty {
                    Text(LocalizedStringKey(title))
                        .fontWeight(.medium)
                }
                Text(LocalizedStringKey(text))
                    .font(!title.isEmpty ? .subheadline : .body)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

