//
//  ItemEditorView.swift
//  LaunchManager
//
//  Created by Yesheng Liang on 12/9/24.
//

import SwiftUI

struct ItemEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: LaunchItem
    
    var body: some View {
        Form {
            HStack {
                Text("Status")
                Spacer()
                Text(item.active ? "Active" : "Inactive")
                    .foregroundColor(item.active ? .green : .red)
            }
            
            Section {
                TextField("Label", text: $item.label, prompt: Text("Required (e.g. com.example.app)"))
                TextField("Command", text: $item.command, prompt: Text("Required (e.g. echo \"Hello world\")"))
                TextField("Working Directory", text: $item.workingDirectory, prompt: Text("Optional (default: /)"))
            }
            
            Section {
                Toggle("Run at Load", isOn: $item.runAtLoad)
                Toggle("Keep Alive", isOn: $item.keepAlive)
                TextField("Start Interval", value: $item.startInterval, format: .number, prompt: Text("None"))
            }
        }
        .disabled(!item.needsUpdate)
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem {
                if item.needsUpdate {
                    Button(action: {
                        item.needsUpdate = false
                        setActive(true)
                    }) {
                        Text("Save")
                    }
                } else {
                    Button(action: {
                        item.needsUpdate = true
                        // Remove file from ~/Library/LaunchAgents
                        setActive(false)
                    }) {
                        Text("Edit")
                    }
                }
            }
            
            if !item.needsUpdate {
                ToolbarItem {
                    Button(action: {
                        setActive(!item.active)
                    }) {
                        Text(item.active ? "Deactivate" : "Activate")
                    }
                }
            }
        }
        .navigationTitle(item.label.isEmpty ? "New Item" : item.label)
        .navigationSubtitle(item.active ? "Active" : "Inactive")
    }
    
    private func setActive(_ active: Bool) {
        if active {
            try? item.activate()
            FilesObserver.shared.add(path: item.plistPath().path)
        } else {
            try? item.deactivate()
            FilesObserver.shared.remove(path: item.plistPath().path)
        }
    }
}
