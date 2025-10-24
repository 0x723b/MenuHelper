//
//  ActionMenuItemEditor.swift
//  MenuHelper
//
//  Created by MenuHelper on 2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ActionMenuItemEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MenuItemStore.self) private var store

    @State private var item: ActionMenuItem
    private let result: Binding<ActionMenuItem>

    init(item: Binding<ActionMenuItem>) {
        self._item = State(wrappedValue: item.wrappedValue)
        result = item
    }

    var body: some View {
        Form {
            HStack {
                Toggle(isOn: $item.enabled) {
                    Text(item.name).font(.title)
                }.toggleStyle(.button)
                Spacer()
                VStack {
                    Image(nsImage: item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    HStack {
                        Button("Choose Icon") {
                            selectCustomIcon()
                        }
                        .buttonStyle(.borderless)
                        if item.customIconData != nil {
                            Button("Reset") {
                                item.customIconData = nil
                                item.customIconType = nil
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .controlSize(.large)
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    result.wrappedValue = item
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle")
                }
            }
        }
    }
    
    private func selectCustomIcon() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        let svgType = UTType(filenameExtension: "svg") ?? UTType(mimeType: "image/svg+xml")!
        panel.allowedContentTypes = [.png, .jpeg, svgType]
        panel.message = "Select an icon image (PNG, JPG, or SVG)"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let data = try Data(contentsOf: url)
                    let fileExtension = url.pathExtension.lowercased()
                    
                    item.customIconData = data
                    if fileExtension == "svg" {
                        item.customIconType = "svg"
                    } else if fileExtension == "jpg" || fileExtension == "jpeg" {
                        item.customIconType = "jpg"
                    } else if fileExtension == "png" {
                        item.customIconType = "png"
                    }
                } catch {
                    print("Error loading icon: \(error)")
                }
            }
        }
    }
}

#Preview {
    struct EditorPreview: View {
        @State private var store = MenuItemStore()
        @State private var item = ActionMenuItem.copyPath
        var body: some View {
            ActionMenuItemEditor(item: $item)
                    .environment(store)
        }
    }
    return EditorPreview()
}
