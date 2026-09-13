//
//  SectionPlatter.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

enum cornerRad {
    static var component: CGFloat {
        if #available(iOS 19.0, *) { return 18 } else { return 12 }
    }
    static var platter: CGFloat {
        if #available(iOS 19.0, *) { return 26 } else { return 18 }
    }
}

// MARK: SectionPlatter
struct SectionPlatter: ViewModifier {
    init() {}
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: cornerRad.platter))
    }
}

