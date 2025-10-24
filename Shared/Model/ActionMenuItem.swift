//
//  ActionMenuItem.swift
//  ActionMenuItem
//
//  Created by Kyle on 2021/10/9.
//

import AppKit
import Foundation

struct ActionMenuItem: MenuItem {
    static func == (lhs: ActionMenuItem, rhs: ActionMenuItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var key: String
    var enabled = true
    var actionIndex: Int?
    var customIconData: Data?
    var customIconType: String?
    var customName: String?
    var script: String?
    var customIdentifier: UUID?

    var isCustom: Bool { customIdentifier != nil }

    var name: String {
        if let customName, !customName.isEmpty {
            return customName
        }
        return String(localized: String.LocalizationValue(key))
    }

    var icon: NSImage {
        if let customIconData, let customIconType {
            return createCustomIcon(from: customIconData, type: customIconType)
        }
        return NSImage(named: "icon")!
    }

    var id: String { customIdentifier?.uuidString ?? key }

    init(key: String, actionIndex: Int, enabled: Bool = true) {
        self.key = key
        self.actionIndex = actionIndex
        self.enabled = enabled
    }

    init(name: String, script: String, enabled: Bool = true, iconData: Data? = nil, iconType: String? = nil, identifier: UUID = UUID()) {
        self.key = name
        self.customName = name
        self.script = script
        self.enabled = enabled
        self.customIconData = iconData
        self.customIconType = iconType
        self.customIdentifier = identifier
        self.actionIndex = nil
    }

    private func createCustomIcon(from data: Data, type: String) -> NSImage {
        if type == "svg" {
            if let image = NSImage(data: data) {
                image.isTemplate = true
                return image
            }
        } else if let image = NSImage(data: data) {
            return image
        }
        return NSImage(named: "icon")!
    }
}

extension ActionMenuItem {
    static var all: [ActionMenuItem] = [.copyPath, copyFileName, .goParent, .newFile]

    static let copyPath = ActionMenuItem(key: "Copy Path", actionIndex: 0)
    static let copyFileName = ActionMenuItem(key: "Copy File Name", actionIndex: 1)
    static let goParent = ActionMenuItem(key: "Go Parent Directory", actionIndex: 2)
    static let newFile = ActionMenuItem(key: "New File", actionIndex: 3)

    // MARK: - Making the compiler to extract Localized key

    #if DEBUG
    // FIXME: - Refactor this when compiler time const is introduced to Swift
    private static let copyPathString = NSLocalizedString("Copy Path", comment: "Copy Path")
    private static let copyFileNameString = NSLocalizedString("Copy File Name", comment: "Copy File Name")
    private static let goParentString = NSLocalizedString("Go Parent Directory", comment: "Go Parent Directory")
    private static let newFileString = NSLocalizedString("New File", comment: "New File")
    #endif
}
