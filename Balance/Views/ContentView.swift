//
//  ContentView.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("goal") var goal: Int = -1500
    @AppStorage("estimationMode") var estimationMode: EstimationMode = .burnOnly
    @Environment(\.refresh) var refresh
    
    let hkHelper = HealthKitHelper.getInstance()
    @State var dateOffset = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $dateOffset) {
                ForEach(-1000..<365) { i in
                    DailySummaryView(date: Date.today.addDays(i))
                        .tag(i)
                }
            }
            .padding(.vertical)
            .navigationBarTitleDisplayMode(.inline)
            .tabViewStyle(.page(indexDisplayMode: .never))
            // .onChange(of: dateOffset) { _ in
            //     if dateOffset == offsets[offsets.count - 1] {
            //         offsets.append(dateOffset + 1)
            //         offsets.remove(at: 0)
            //     } else if dateOffset == offsets[0] {
            //         offsets.insert(dateOffset - 1, at: 0)
            //         offsets.remove(at: offsets.count - 1)
            //     }
            // }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink("Settings") {
                        SettingsView()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Button(Date.today.addDays(dateOffset).relativeString) {
                        withAnimation {
                            dateOffset = 0
                        }
                    }
                    .foregroundColor(.primary)
                    .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        refresh.send()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
