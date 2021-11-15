//
//  ContentView.swift
//  Waveforms
//
//  Created by John Matthew Weston on 10/17/21.
//

import SwiftUI

class ProviderAdapter: ObservableObject {

    @Published var sampleSize: Int = 100 {
        didSet {
            fetch()
        }
    }
    @Published var data = [CGFloat]()

    func fetch() {
        data.removeAll()
        HealthKitDataProvider.instance.queryECGSamplesForDistantRange(samples: sampleSize ) { [self] result in
            DispatchQueue.main.async {
                //print("RESULT: \(result)")
                let values = Array(result.values)
                for value in values {
                    var element = CGFloat(value)
                    data.append( element )
                }
                print("\(#function): \(data.count) ECG samples received")
            }
        }
    }
}

struct ContentView: View {
    var input: [Float]
    var sampleData: [CGFloat]
    
    @State private var update = false
    @State var on = true
    
    @ObservedObject var providerAdapter = ProviderAdapter()
    
    //async
    public init()  {
        sampleData = [0.1, 0.2, 0.3, 0.4, 0.5]
        input = [3.9, 7.7, 11.1, 1.11, 1.02, 3.3, 3.9, 0]

        HealthKitDataProvider.instance.requestHealthKitAuthorization()

        let algorithms = AlgorithAdapter()
        let output = algorithms.execute( inputArray: input )

        let engine = CalculateDerivedMeasures()
        if #available(iOS 15.0.0, *) {
            let output = engine.execute(input: self.input)
            var update = output.map{CGFloat($0)}
        } else {
            // Fallback on earlier versions
        }
 
    }

    var body: some View {
          VStack {
            Text("WAVEFORMS")
                .padding()
            LineView(data: [0.1, 2.0, 3.0, 4.0 ], title: "SERIES" )
                  .padding()
            ChartView(xStepValue: 1, yStepValue: 8)
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
        .onAppear {
            self.providerAdapter.fetch()
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
