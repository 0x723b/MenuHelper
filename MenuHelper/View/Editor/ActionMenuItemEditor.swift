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
    private let onSave: ((ActionMenuItem) -> Void)?

    private var customNameBinding: Binding<String> {
        Binding<String> {
            item.customName ?? ""
        } set: { newValue in
            item.customName = newValue
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                item.key = newValue
            }
        }
    }

    private var scriptBinding: Binding<String> {
        Binding<String> {
            item.script ?? ""
        } set: { newValue in
            item.script = newValue
        }
    }

    private var isSaveDisabled: Bool {
        guard item.isCustom else { return false }
        let name = item.customName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let script = item.script?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty || script.isEmpty
    }

    init(item: Binding<ActionMenuItem>, onSave: ((ActionMenuItem) -> Void)? = nil) {
        self._item = State(wrappedValue: item.wrappedValue)
        result = item
        self.onSave = onSave
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
            if item.isCustom {
                Section {
                    TextField(text: customNameBinding) {
                        Text("Script Name")
                    }
                }
                Section {
                    TextEditor(text: scriptBinding)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 160)
                        .overlay {
                            if (item.script ?? "").isEmpty {
                                Text("echo \"$MENU_HELPER_PRIMARY_PATH\"")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                            }
                        }
                } footer: {
                    Text("Available environment variables:\nMENU_HELPER_PRIMARY_PATH: First selected file\nMENU_HELPER_SELECTED_PATHS: All selected files (newline separated)\nMENU_HELPER_SELECTED_COUNT: Number of selected files\nMENU_HELPER_SELECTED_PATH_0, _1, etc: Individual file paths")
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
                    if item.isCustom {
                        item.customName = item.customName?.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let trimmed = item.customName, !trimmed.isEmpty {
                            item.key = trimmed
                        }
                        item.script = item.script?.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    result.wrappedValue = item
                    onSave?(item)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.circle")
                }
                .disabled(isSaveDisabled)
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
