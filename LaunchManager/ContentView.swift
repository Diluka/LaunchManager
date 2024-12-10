//
//  ContentView.swift
//  LaunchManager
//
//  Created by Yesheng Liang on 12/9/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [LaunchItem]
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        Text(item.label.isEmpty ? "New Item" : item.label)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            try? item.deactivate()
                            modelContext.delete(item)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationDestination(for: LaunchItem.self) { item in
                ItemEditorView(item: item)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = LaunchItem()
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                try? items[index].deactivate()
                modelContext.delete(items[index])
            }
        }
    }
    
    private func toggleItemActivation(_ item: LaunchItem) {
        withAnimation {
            item.active.toggle()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LaunchItem.self, inMemory: true)
}
