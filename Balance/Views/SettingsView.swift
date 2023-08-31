//
//  SettingsView.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("goal") var goal: Int = GoalKey.defaultValue
    @AppStorage("estimationMode") var estimationMode: EstimationMode = EstimationModeKey.defaultValue

    @State var goalText: String = "-1500"
    @FocusState var goalFieldFocused: Bool
    
    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = false
        return formatter
    }()
    
    var body: some View {
        Form {
            LabeledContent {
                // TextField("Goal", value: $goal, formatter: intFormatter)
                //     .textFieldStyle(RoundedBorderTextFieldStyle())
                //     .keyboardType(.numberPad)
                //     .frame(width: 80)
                //     .focused($goalFieldFocused)
                // .buttonStyle(.borderedProminent)
                // .buttonBorderShape(.roundedRectangle)
                TextField("Goal", text: Binding(
                    get: { goalText },
                    set: { value in
                        goalText = value
                        if let i = Int(value) {
                            goal = i
                        }
                    })
                )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                    .focused($goalFieldFocused)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
            } label: {
                Text("Goal")
            }
            VStack(alignment: .leading) {
                Text("Estimate Future Calories?")
                Picker("Estimate Future Calories?", selection: $estimationMode) {
                    ForEach(EstimationMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                Text("\(estimationMode.explanation) Estimates are used for future dates, the remainder of today (prorated), and past dates where no data is available.")
                    .font(.caption)
            }
        }
        .onAppear {
            goalText = "\(goal)"
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("+/-") {
                    goal = -goal
                    if goalText.hasPrefix("-") {
                        goalText = String(goalText.suffix(goalText.count - 1))
                    } else {
                        goalText = "-\(goalText)"
                    }
                }
            }
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    goalFieldFocused = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    struct SettingsViewPreviewWrapper: View {
        @State var goal = -1500
        @State var estimationMode = EstimationMode.burnOnly
        var body: some View {
            SettingsView()
        }
    }
    static var previews: some View {
        SettingsViewPreviewWrapper()
    }
}
