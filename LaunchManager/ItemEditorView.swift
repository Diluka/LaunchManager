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
//            State: active?
            HStack {
                Text("Status")
                Spacer()
                Text(item.active ? "Active" : "Inactive")
                    .foregroundColor(item.active ? .green : .red)
                
            }
            
            Section(header: Text("General")) {
                TextField("Label", text: $item.label, prompt: Text("com.example.app"))
                TextField("Command", text: $item.command, prompt: Text("echo \"Hello, World!\""))
                Toggle("Run at Load", isOn: $item.runAtLoad)
                Toggle("Keep Alive", isOn: $item.keepAlive)
                TextField("Start Interval", value: $item.startInterval, format: .number, prompt: Text("None"))
                TextField("Working Directory", text: $item.workingDirectory, prompt: Text("Optional"))
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
                    }) {
                        Text("Edit")
                    }
                }
            }
            
            ToolbarItem {
                
                Button(action: {
                    setActive(!item.active)
                }) {
                    Text(item.active ? "Deactivate" : "Activate")
                }

            }
        }
        .navigationTitle(item.label.isEmpty ? "New Item" : item.label)
        .navigationSubtitle(item.active ? "Active" : "Inactive")
    }
    
    private func setActive(_ active: Bool) {
        if active {
            try? item.activate()
        } else {
            try? item.deactivate()
        }
    }
    
        
    private func removePlist() {
        let libraryDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let launchAgentsFolder = libraryDirectory.appendingPathComponent("LaunchAgents")
        guard launchAgentsFolder.startAccessingSecurityScopedResource() else {
            print("Could not access LaunchAgents folder")
            return
        }
        let plistFile = launchAgentsFolder.appendingPathComponent("\(item.label).plist")
        do {
            try FileManager.default.removeItem(at: plistFile)
        } catch {
            print("Could not remove plist: \(error)")
            return
        }
    }

}
