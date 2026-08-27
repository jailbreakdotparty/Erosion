//
//  Extensions.swift
//  SymlinkSurprise
//
//  Created by lunginspector on 8/12/26.
//

import SwiftUI

// FileManager++
extension FileManager {
    func createDirIfNeeded(at url: URL) throws {
        if !self.fileExists(atPath: url.path) {
            try? self.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}

// Arrays+AppStorage
extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

// String+Error
extension String: @retroactive Error {}

// ButtonRole++
extension ButtonRole {
    static var adaptiveConfirm: ButtonRole? {
        if #available(iOS 19.0, *) {
            return .confirm
        }
        return nil
    }
}

func isSolariumUI() -> Bool {
    if #available(iOS 19.0, *) {
        return true
    }
    return false
}
