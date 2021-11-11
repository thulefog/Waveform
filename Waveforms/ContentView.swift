//
//  ContentView.swift
//  Waveforms
//
//  Created by John Matthew Weston on 10/17/21.
//

import SwiftUI

struct ContentView: View {
    var input: [Float]
    var sampleData: [CGFloat]
    
    @State private var update = false
    @State var on = true
    
    //async
    public init()  {
        sampleData = [0.1, 0.2, 0.3, 0.4, 0.5]
    
        let requestAuthorization = RequestHealthKitAuthorizationAsync()
        
        HealthKitDataProvider.instance.queryAverageHeartRate()
        HealthKitDataProvider.instance.queryElectorcardiogramSamplesForRange()
        
        var algorithms = AlgorithAdapter()
        input = [3.9, 7.7, 11.1, 1.11, 1.02, 3.3, 3.9, 0]
        let output = algorithms.execute( inputArray: input )

        var engine = CalculateDerivedMeasures()
        if #available(iOS 15.0.0, *) {
            var output = engine.execute(input: self.input)
            var update = output.map{CGFloat($0)}
        } else {
            // Fallback on earlier versions
        }
        
        let fetchHeartRateVariabilitySDNN = FetchHeartRateVariabilityForDateRange()
         
        let opQueue = OperationQueue()
        opQueue.addOperation(requestAuthorization)
        opQueue.addOperation(fetchHeartRateVariabilitySDNN)
         
    }

    var body: some View {
          VStack {
            Text("WAVEFORMS")
                .padding()
            LineView(data: [0.1, 2.0, 3.0, 4.0 ], title: "SERIES" )
                  .padding()
            LineGraph(dataPoints: sampleData)
                .trim(to: on ? 1 : 0)
                .stroke(Color.gray, lineWidth: 2)
                .aspectRatio(16/9, contentMode: .fit)
                .border(Color.gray, width: 1)
                .background(Color.black)
                .padding()
                .onTapGesture{
                    self.update.toggle()
                }
            Button("Animate") {
                withAnimation(.easeInOut(duration: 2)) {
                    self.on.toggle()
                }
            }
        }
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
