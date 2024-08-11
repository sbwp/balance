//
//  DoubleField.swift
//  Balance
//
//  Created by Sabrina Bea on 6/16/24.
//

import SwiftUI

struct DoubleField: View {
    let label: String
    @Binding var value: Double?
    
    init(_ label: String, value: Binding<Double?>) {
        self.label = label
        self._value = value
    }
    
    init(_ label: String, value: Binding<Double>) {
        self.label = label
        self._value = Binding(get: { value.wrappedValue }, set: { value.wrappedValue = $0 ?? 0 })
    }
    
    var body: some View {
        TextField(label, value: $value, format: .number)
            .keyboardType(.decimalPad)
            .fullyTappable()
    }
}

#Preview {
    IntegerField("Calories", value: .constant(50))
}
