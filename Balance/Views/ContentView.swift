//
//  ContentView.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("goal") var goal: Int = -1500
    @AppStorage("bmrEstimationMode") var bmrEstimationMode: BmrEstimationMode = BmrEstimationModeKey.defaultValue
    @AppStorage("neatEstimationMode") var neatEstimationMode: NeatEstimationMode = NeatEstimationModeKey.defaultValue
    @Environment(\.refresh) var refresh
    @Environment(\.scenePhase) var scenePhase
    
    let hkHelper = HealthKitHelper.getInstance()
    @State var dateOffset = 0
    @State var displayWeight = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $dateOffset) {
                ForEach(-1000..<1) { i in
                    DailySummaryView(date: Date.today.addDays(i), doCalculation: i == dateOffset, displayWeight: $displayWeight)
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
            .onAppear(perform: { refresh.send() })
            .onChange(of: bmrEstimationMode, perform: { _ in refresh.send() })
            .onChange(of: neatEstimationMode, perform: { _ in refresh.send() })
            .onChange(of: dateOffset, perform: { _ in
                refresh.send()
            })
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    refresh.send()
                }
            }
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
                        hkHelper.forceNeatRecalc()
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
