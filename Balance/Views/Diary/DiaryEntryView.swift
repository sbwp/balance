//
//  DiaryEntryView.swift
//  Balance
//
//  Created by Sabrina Bea on 1/1/24.
//

import SwiftUI

struct DiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pantry: Pantry
    
    let diaryEntry: DiaryEntry
    
    var body: some View {
        HStack {
            Text("\(diaryEntry.title), \(diaryEntry.measurementDescription)")
            Spacer()
            Text("\(diaryEntry.calories)")
        }
        .contextMenu(ContextMenu(menuItems: {
            NavigationLink {
                EditDiaryEntryView(diaryEntry: diaryEntry)
                    .onDisappear {
                        dismiss()
                    }
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                Task.detached { @MainActor in
                    await pantry.deleteDiaryEntry(diaryEntry)
                }
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundStyle(.red)
            }
        }))
    }
}

#Preview {
    DiaryEntryView(diaryEntry: DiaryEntry(meal: .breakfast, food: Food("Nachos", 500, grams: 500), grams: 500))
}
