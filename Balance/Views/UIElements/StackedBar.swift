//
//  StackedBar.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import SwiftUI

struct StackedBar: View {
    let values: [Int]
    let colors: [Color]
    let maxValue: Int
    
    var shouldRoundCorner: Bool {
        values.reduce(0, { sum, next in sum + next }) <= maxValue
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    ForEach(Array(values.enumerated().reversed()), id: \.1) { index, value in
                        Rectangle().frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: geometry.size.height)
                            .foregroundColor(colors[index % colors.count])
                    }
                }
                .cornerRadius(shouldRoundCorner ? 20 : 0, corners: [.topLeft, .bottomLeft])
            }
        }
        .frame(height: 20)
    }
}

struct StackedBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StackedBar(values: [3000, 650, 725], colors: [.yellow, .green, .blue], maxValue: 6000)
            StackedBar(values: [2000, 650, 72], colors: [.blue, .green, .purple], maxValue: 6000)
            StackedBar(values: [1500, 650, 723], colors: [.blue, .green], maxValue: 6000)
            StackedBar(values: [3500], colors: [.orange], maxValue: 6000)
            StackedBar(values: [1000, 600, 3200], colors: [.gray], maxValue: 6000)
            StackedBar(values: [9000], colors: [.red], maxValue: 6000)
            StackedBar(values: [1000, 5000], colors: [.purple, .teal], maxValue: 6000)
            StackedBar(values: [2000, 4001], colors: [.indigo, .brown], maxValue: 6000)
        }
    }
}
