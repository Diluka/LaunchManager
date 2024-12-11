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
    @Query(sort: \LaunchItem.createdAt) private var items: [LaunchItem]
    
    @State private var presentedItem: LaunchItem?
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        Label {
                            Text(item.label.isEmpty ? "New Item" : item.label)
                        } icon: {
                            Image(systemName: "circle")
                                .foregroundColor(item.active ? .green : .gray)
                        }
                    
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
                    .frame(minWidth: 300, idealWidth: 600)
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
        .onAppear {
            FilesObserver.shared.set(files: items.filter(\.active).map { $0.plistPath().path })
        }
        .onChange(of: items) {
            Task(priority: .background) {
                let files = items.filter(\.active).map { $0.plistPath().path }
                FilesObserver.shared.set(files: files)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .fileRemoved)) { notification in
            let path = notification.object as! String
            let label = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
            items.filter({ $0.label == label }).forEach { $0.active = false }
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
