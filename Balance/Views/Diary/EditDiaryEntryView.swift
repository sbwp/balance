// ©2024 Sabrina Bea. All rights reserved.

import SwiftUI

struct EditDiaryEntryView: View {
    @EnvironmentObject var pantry: Pantry
    @State var selection: [DiaryEntry] = []
    var diaryEntry: DiaryEntry
    
    var body: some View {
        CreateDiaryEntryView(selection: $selection, oldEntry: diaryEntry, food: pantry.getFoodForDiaryEntry(diaryEntry))
            .onChange(of: selection) {
                Task.detached { @MainActor in
                    if selection.count > 0 {
                        await pantry.addOrUpdateDiaryEntry(selection[selection.count - 1])
                    }
                }
            }
    }
}

#Preview {
    EditDiaryEntryView(diaryEntry: .forPreview)
}
