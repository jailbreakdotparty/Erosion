//
//  PlistManager.swift
//  Filos
//
//  Created by lunginspector on 7/25/26.
//

import SwiftUI
import Combine

/*
 i took on a bit of an ambitious goal: making a plist editor that works properly and has a bunch of features.
 
 to actually get the data, i decided to cast the raw data from a plist as [String : Any], which is the usual swift format of plists. then, i converted [String : Any] into an array that contains my own custom item. it stores the key and the raw value, gets the type (getType()), converts the value into a boolean, string, and dictionary for editing, and then can be converted back into [String : Any] when calling getRawValue() on the plist item.
 
 for editing plists, i used a manager that stores the converted [PlistItem] array, and is binding throughout the views for viewing. however, for actually editing, i decided to manually edit instead of using bindings, as i had attempted to use a binding-based system to avoid wrappers, but it was incredibly unstable.
 
 it's not the best editor in the world, and could definetely use some improvements and modifications, but it works pretty well for the time being and seems to be able to write to system plists without messing them up.
 */

final class PlistManager: ObservableObject {
    static let shared = PlistManager()
    
    @Published var plistArray: [PlistItem] = []
    @Published var url: URL = URL.documentsDirectory.appendingPathComponent("oops")
    @Published var isWritable = false
    
    init() {}
    
    func loadPlistItems() -> Bool {
        plistArray = [PlistItem(key: "Root", value: [], isExpanded: true)]
        if let rawDict = getFileDict(url) {
            for key in rawDict.keys {
                if let value = rawDict[key] {
                    plistArray[0].dictVal.append(PlistItem(key: key, value: value))
                }
            }
            plistArray = plistArray.sorted(by: { $0.key < $1.key })
            return true
        } else {
            print("[!] failed to load plist as it seems like there was no passable dictionary?")
        }
        return false
    }
    
    func writePlistItems(newItem: PlistItem? = nil, delItem: PlistItem? = nil) -> Bool {
        if let newItem {
            let res = replacePlistItem(items: &plistArray, newItem: newItem)
            if !res {
                print("[!] failed to write plist: couldn't find \(newItem.key) in dictionary.")
            }
        }
        
        if let delItem {
            let res = deletePlistItem(items: &plistArray, target: delItem)
            if !res {
                print("[!] failed to write plist: couldn't find \(delItem.key) in dictionary.")
            }
        }
        
        var dictToWrite: [String : Any] = [:]
        
        for item in plistArray[0].dictVal {
            dictToWrite[item.key] = item.getRawValue()
        }
    
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dictToWrite, format: .binary, options: 0)
            try data.write(to: url)
            return true
        } catch {
            print("[!] failed to write plist: \(error)")
        }
        return false
    }
    
    // not a huge fan of any of this...
    func replacePlistItem(items: inout [PlistItem], newItem: PlistItem) -> Bool {
        for item in items.indices {
            if items[item].id == newItem.id {
                items[item] = newItem
                return true
            }
            
            if replacePlistItem(items: &items[item].dictVal, newItem: newItem) {
                return true
            }
        }
        return false
    }
    
    func deletePlistItem(items: inout [PlistItem], target: PlistItem) -> Bool {
        for item in items.indices {
            if items[item].id == target.id {
                items.removeAll() { $0.id == target.id }
                return true
            }
            
            if deletePlistItem(items: &items[item].dictVal, target: target) {
                return true
            }
        }
        return false
    }
}

struct PlistItem: Identifiable {
    var id = UUID()
    var key: String
    var rawVal: Any?
    var type: PlistItemType = .unknown
    var index: Int?
    var isExpanded: Bool
    
    var stringVal: String = ""
    var boolVal: Bool = false
    var dictVal: [PlistItem] = []
    
    init(key: String, value: Any, isExpanded: Bool = false) {
        self.key = key
        self.rawVal = value
        self.isExpanded = isExpanded
        self.type = getType()
        
        switch rawVal {
        case let v as String: self.stringVal = v
        case let v as Int: self.stringVal = String(v)
        case let v as Double: self.stringVal = String(v)
        case let v as Bool: self.boolVal = v
        case let v as Data: self.stringVal = v.base64EncodedString()
        case let v as [String : Any]:
            self.dictVal = v.map {
                PlistItem(key: $0.key, value: $0.value)
            }.sorted(by: { $0.key < $1.key })
            self.stringVal = v.description
        case let v as [Any]:
            self.dictVal = v.enumerated().map { index, value in
                var newItem = PlistItem(key: "Item \(index)", value: value)
                newItem.index = index
                return newItem
            }
            self.stringVal = v.description
        default: break
        }
    }
    
    private func getType() -> PlistItemType {
        switch rawVal {
        case is String: return .string
        case is Int: return .int
        case is Double: return .double
        case is Bool: return .bool
        case is Data: return .data
        case is [String : Any]: return .dict
        case is [Any]: return .array
        default: return .unknown
        }
    }
    
    func getRawValue() -> Any {
        switch type {
        case .string: return stringVal
        case .int: return Int(stringVal) ?? 0
        case .double: return Double(stringVal) ?? 0
        case .bool: return boolVal
        // case .data: return Data(stringVal.utf8)
        case .data: return rawVal ?? Data()
        case .dict:
            var rawDict = [String : Any]()
            for item in dictVal {
                rawDict[item.key] = item.getRawValue()
            }
            return rawDict
        case .array:
            var rawArray = [Any]()
            for item in dictVal {
                rawArray.append(item.getRawValue())
            }
            return rawArray
        case .unknown: return rawVal ?? ""
        }
    }
}

enum PlistItemType: String, CaseIterable {
    case string, int, double, bool, data, dict, array, unknown
    
    var label: String {
        switch self {
        case .string: return "String"
        case .int: return "Integer"
        case .double: return "Double"
        case .bool: return "Boolean"
        case .data: return "Data"
        case .dict: return "Dictionary"
        case .array: return "Array"
        default: return "Unknown"
        }
    }
}
