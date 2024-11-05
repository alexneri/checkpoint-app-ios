//
//  ContentView.swift
//  CheckpointApp
//
//  Created by Alexander Nicholas Neri on 24/10/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .forward) private var items: [Item] // Ensure items are sorted by timestamp ascending

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    // Use a ternary operator to assign "N/A" or the formatted time difference
                    let timeDifference = index == 0
                        ? "N/A"
                        : formatTimeInterval(item.timestamp.timeIntervalSince(items[index - 1].timestamp))
                    
                    NavigationLink {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Checkpoint created at \(item.timestamp, format: Date.FormatStyle(date: .complete, time: .complete))")
                            Text("Time since last checkpoint: \(timeDifference)")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.timestamp, format: Date.FormatStyle(date: .complete, time: .complete))
                                    .padding(5)
                                    .background(Color.green.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                                Text("Checkpoint")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(timeDifference)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
                .foregroundColor(.secondary)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    /// Formats a time interval into a human-readable string.
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let absInterval = abs(interval)
        if absInterval < 60 {
            return "\(Int(absInterval)) second\(Int(absInterval) == 1 ? "" : "s")"
        } else if absInterval < 3600 {
            let minutes = Int(absInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else if absInterval < 86400 {
            let hours = Int(absInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            let days = Int(absInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s")"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

