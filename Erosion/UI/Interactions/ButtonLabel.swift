//
//  ButtonLabel.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

struct ButtonLabel: View {
    var text: String
    var symbol: String
    var useImage: Bool
    
    init(_ text: String, symbol: String, useImage: Bool = false) {
        self.text = text
        self.symbol = symbol
        self.useImage = useImage
    }
    
    var body: some View {
        HStack {
            if symbol == "showMeProgressPlease" {
                ProgressView()
                    .frame(width: 20, height: 20, alignment: .center)
                    .offset(y: 0.5)
            } else {
                if useImage {
                    Image(symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                } else {
                    Image(systemName: symbol)
                        .frame(width: 22, height: 22, alignment: .center)
                }
            }
            Text(text)
        }
        .font(.body.weight(.medium))
    }
}
