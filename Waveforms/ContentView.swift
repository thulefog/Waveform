//
//  ContentView.swift
//  Waveforms
//
//  Created by John Matthew Weston on 10/17/21.
//

import SwiftUI



struct ContentView: View {
    
    @ObservedObject var healthDataReader = HealthDataReader()
    
    //async
    public init()  {
        
        HealthDataAdapter.instance.requestHealthKitAuthorization()
    }
    
    var body: some View {
        VStack {
            Text("Waveform")
                .padding()
            
            ScrollableTimeSeriesChart(data: healthDataReader.data )
        }
        .preferredColorScheme(.dark)
        .onAppear {
            self.healthDataReader.retrieveElectrocardiogramTimeSeries()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
