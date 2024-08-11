//
//  SettingsView.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("goal") var goal: Int = GoalKey.defaultValue
    @AppStorage("defaultNeat") var defaultNeat: Int = DefaultNeatKey.defaultValue
    @AppStorage("defaultBmr") var defaultBmr: Int = DefaultBmrKey.defaultValue
    @AppStorage("bmrEstimationMode") var bmrEstimationMode: BmrEstimationMode = BmrEstimationModeKey.defaultValue
    @AppStorage("neatEstimationMode") var neatEstimationMode: NeatEstimationMode = NeatEstimationModeKey.defaultValue

    @State var goalText: String = "-1500"
    @State var defaultNeatText: String = "600"
    @State var defaultBmrText: String = "3000"
    @FocusState var goalFieldFocused: Bool
    @FocusState var defaultNeatFocused: Bool
    @FocusState var defaultBmrFocused: Bool
    
    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = false
        return formatter
    }()
    
    let defaultNeatExplanation = "Default NEAT is used when the watch is not worn and no data is available for the entire day."
    
    let defaultBmrExplanation = "Default BMR is used when the watch is not worn and no data is available for the entire day."
    
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
                Text("Estimate \(EnergyType.bmr.descriptiveName)?")
                Picker("Estimate \(EnergyType.bmr.descriptiveName)?", selection: $bmrEstimationMode) {
                    ForEach(BmrEstimationMode.allCases, id: \.self) { mode in
                        Text(mode.descriptiveName)
                    }
                }
                .pickerStyle(.segmented)
                Text(bmrEstimationMode.explanation)
                    .font(.caption)
            }
            VStack(alignment: .leading) {
                Text("Estimate \(EnergyType.nonexercise.descriptiveName)?")
                Picker("Estimate \(EnergyType.nonexercise.descriptiveName)?", selection: $neatEstimationMode) {
                    ForEach(NeatEstimationMode.allCases, id: \.self) { mode in
                        Text(mode.descriptiveName)
                    }
                }
                .pickerStyle(.segmented)
                Text(neatEstimationMode.explanation)
                    .font(.caption)
            }
            
            
            VStack(alignment: .leading) {
                LabeledContent {
                    TextField("Default NEAT", text: Binding(
                        get: { defaultNeatText },
                        set: { value in
                            defaultNeatText = value
                            if let i = Int(value) {
                                defaultNeat = i
                            }
                        })
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                    .focused($defaultNeatFocused)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                } label: {
                    Text("Default NEAT")
                }
                
                Text(defaultNeatExplanation)
                    .font(.caption)
            }
            
            VStack(alignment: .leading) {
                LabeledContent {
                    TextField("Default BMR", text: Binding(
                        get: { defaultBmrText },
                        set: { value in
                            defaultBmrText = value
                            if let i = Int(value) {
                                defaultBmr = i
                            }
                        })
                    )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .focused($defaultBmrFocused)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                } label: {
                    Text("Default BMR")
                }
                
                Text(defaultBmrExplanation)
                    .font(.caption)
            }
            
            NavigationLink("Definitons") {
                DefinitionsView()
            }
        }
        .onAppear {
            goalText = "\(goal)"
            defaultNeatText = "\(defaultNeat)"
            defaultBmrText = "\(defaultBmr)"
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("+/-") {
                    if goalFieldFocused {
                        goal = -goal
                        if goalText.hasPrefix("-") {
                            goalText = String(goalText.suffix(goalText.count - 1))
                        } else {
                            goalText = "-\(goalText)"
                        }
                    }
                }
                .disabled(!goalFieldFocused)
            }
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    goalFieldFocused = false
                    defaultNeatFocused = false
                    defaultBmrFocused = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    struct SettingsViewPreviewWrapper: View {
        @State var goal = -1500
        @State var bmrEstimationMode = BmrEstimationMode.median
        @State var neatEstimationMode = NeatEstimationMode.minimum
        var body: some View {
            SettingsView()
        }
    }
    static var previews: some View {
        SettingsViewPreviewWrapper()
    }
}
