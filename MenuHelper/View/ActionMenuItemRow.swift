//
//  ActionMenuItemRow.swift
//  MenuHelper
//
//  Created by MenuHelper on 2024.
//

import SwiftUI

struct ActionMenuItemRow: View {
    @Environment(MenuItemStore.self) private var store
    @State private var editingItem = false
    @Binding var item: ActionMenuItem

    var body: some View {
        HStack {
            Image(nsImage: item.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            Toggle(isOn: $item.enabled) {
                Text(item.name)
            }.toggleStyle(.button)
        }
        .contextMenu {
            Button {
                editingItem = true
            } label: {
                Label(item.isCustom ? "Edit Script" : "Edit Icon", systemImage: "pencil")
            }
            if item.isCustom {
                Button(role: .destructive) {
                    store.deleteActionItem(id: item.id)
                } label: {
                    Label("Delete Script", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $editingItem, onDismiss: nil) {
            ActionMenuItemEditor(item: $item)
                .environment(store)
        }
    }
}
