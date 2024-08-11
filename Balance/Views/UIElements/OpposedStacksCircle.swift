//
//  SegmentedCircle.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import SwiftUI

struct OpposedStacksCircle: View {
    let valuesLeft: [Int]
    let colorsLeft: [Color]
    
    let valuesRight: [Int]
    let colorsRight: [Color]
    
    private var geometryValuesList: [CircleGeometryValues] {
        var lastTrimEnd: CGFloat = 0
        var geometryValuesList = valuesRight.enumerated().map({ index, value in
            let old = lastTrimEnd
            lastTrimEnd += CGFloat(value) / maxValue
            return CircleGeometryValues(trimStart: old, trimEnd: lastTrimEnd, color: colorsRight[index % colorsRight.count], isThick: totalLeft < totalRight)
        })
        
        geometryValuesList.append(contentsOf: valuesLeft.reversed().enumerated().map({ index, value in
            let old = lastTrimEnd
            lastTrimEnd += CGFloat(value) / maxValue
            return CircleGeometryValues(trimStart: old, trimEnd: lastTrimEnd, color: colorsLeft[index % colorsLeft.count], isThick: totalLeft > totalRight)
        }))
        return geometryValuesList
    }
    
    var totalLeft: Int {
        return valuesLeft.reduce(0, { sum, next in sum + next })
    }
    
    var totalRight: Int {
        return valuesRight.reduce(0, { sum, next in sum + next })
    }
    
    var maxValue: CGFloat {
        return CGFloat(totalLeft + totalRight)
    }
    
    private var overhang: CircleGeometryValues {
        return totalLeft < totalRight
            ? CircleGeometryValues(trimStart: 0.5, trimEnd: CGFloat(totalRight) / maxValue)
            : CircleGeometryValues(trimStart: 1 - (CGFloat(totalLeft) / maxValue), trimEnd: 0.5)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                ZStack() {
                    ForEach(Array(geometryValuesList.enumerated()), id: \.0) { index, geometryValues in
                        Circle()
                            .trim(from: geometryValues.trimStart, to: geometryValues.trimEnd)
                            .stroke(geometryValues.color, lineWidth: geometryValues.isThick ? (geometry.size.width * 0.1).rounded(.up) : (geometry.size.width * 0.0667).rounded(.up))
                    }
                    
                    // Thin Line
                    Circle()
                        .trim(from: overhang.trimStart, to: overhang.trimEnd)
                        .stroke(.primary, lineWidth: 2)
                        .padding((geometry.size.width * 0.1).rounded(.up))
                    
                    // Thin Line Ends
                    Circle()
                        .trim(from: overhang.trimStart, to: overhang.trimStart + overhangEndCapStrokeWidth(geometry))
                        .stroke(.primary, lineWidth: (geometry.size.width * 0.0667).rounded(.up))
                        .padding((geometry.size.width * 0.1).rounded(.up))
                    Circle()
                        .trim(from: overhang.trimEnd - overhangEndCapStrokeWidth(geometry), to: overhang.trimEnd)
                        .stroke(.primary, lineWidth: (geometry.size.width * 0.0667).rounded(.up))
                        .padding((geometry.size.width * 0.1).rounded(.up))
                }
                .rotationEffect(.degrees(-90))
            }
        }
    }
    
    func overhangEndCapStrokeWidth(_ geometry: GeometryProxy) -> CGFloat {
        let circumference = CGFloat.pi * CGFloat.minimum(geometry.size.width, geometry.size.height)
        return 2 / circumference
    }
}

private struct CircleGeometryValues {
    let trimStart: CGFloat
    let trimEnd: CGFloat
    let color: Color
    let isThick: Bool
    
    init(trimStart: CGFloat, trimEnd: CGFloat, color: Color = .black, isThick: Bool = false) {
        self.trimStart = trimStart
        self.trimEnd = trimEnd
        self.color = color
        self.isThick = isThick
    }
}

struct SegmentedCircle_Previews: PreviewProvider {
    static var previews: some View {
        OpposedStacksCircle(valuesLeft: [592], colorsLeft: [.yellow, .green, .blue], valuesRight: [3152, 750], colorsRight: [.blue, .green, .purple])
            .padding(50)
        OpposedStacksCircle(valuesLeft: [3152, 592], colorsLeft: [.yellow, .green, .blue], valuesRight: [750], colorsRight: [.blue, .green, .purple])
            .padding(50)
        OpposedStacksCircle(valuesLeft: [592], colorsLeft: [.yellow, .green, .blue], valuesRight: [3152, 750], colorsRight: [.blue, .green, .purple])
            .frame(width: 100, height: 100)
            .padding(50)
    }
}
