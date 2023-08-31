//
//  DateFlipper.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import SwiftUI

struct DateFlipper: View {
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                date = date.addDays(-1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(.primary)
            
            Button("\(date.relativeString)") {
                date = Date().startOfDay
            }
            .font(.headline)
            .foregroundColor(.primary)
            
            Button {
                date = date.addDays(1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct DateFlipper_Previews: PreviewProvider {
    static var previews: some View {
        DateFlipper(date: .constant(Date()))
    }
}
