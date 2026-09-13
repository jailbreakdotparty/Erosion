//
//  AppInfoCell.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

struct AppInfoCell: View {
    let build: String
    
    var body: some View {
        HStack(spacing: 14) {
            AppIconCell(image: Image(uiImage: AppInfo.appIcon ?? UIImage()))
            VStack(alignment: .leading) {
                Text(AppInfo.appName)
                    .font(.title3.weight(.semibold))
                Text("Version \(AppInfo.appVersion) (\(build))")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AppIconCell: View {
    var image: Image
    
    var body: some View {
        if #available(iOS 19.0, *) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .background(PlaceholderAppIconCell())
                .clipShape(.rect(cornerRadius: 18))
                .glassEffect(.regular, in: .rect(cornerRadius: 18))
        } else {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .background(PlaceholderAppIconCell())
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1.5)
                }
        }
    }
}

struct PlaceholderAppIconCell: View {
    var body: some View {
        Image(systemName: "questionmark.square")
            .foregroundStyle(.secondary)
            .frame(width: 64, height: 64)
            .background(Color(.systemGray5))
    }
}
