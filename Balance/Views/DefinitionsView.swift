//
//  DefinitionsView.swift
//  Balance
//
//  Created by Sabrina Bea on 9/20/23.
//

import SwiftUI

struct DefinitionsView: View {
    @State var selectedEnergyType: EnergyType? = nil
    var body: some View {
        ZStack {
            List {
                ForEach(EnergyType.allCases, id: \.self) { energyType in
                    Text(.init(energyType.basicExplanation + (selectedEnergyType == energyType ? "\n\n\(energyType.extendedExplanation)" : "")))
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedEnergyType = selectedEnergyType == energyType ? nil : energyType
                            }
                        }
                }
                Label("Tap on a definition for more information.", systemImage: "info.circle")
                    .labelStyle(.titleAndIcon)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        
    }
}

#Preview {
    DefinitionsView()
}
