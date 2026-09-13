//
//  ToolbarLabel.swift
//  PartyUI
//
//  Created by lunginspector on 7/27/26.
//

import SwiftUI

struct ToolbarLabel: View {
    var label: String
    var symbol: String
    
    init(_ label: String, symbol: String) {
        self.label = label
        self.symbol = symbol
    }
    
    var body: some View {
        if #available(iOS 19.0, *) {
            Label(label, systemImage: symbol)
                .labelStyle(.iconOnly)
        } else {
            Text(label)
        }
    }
}
