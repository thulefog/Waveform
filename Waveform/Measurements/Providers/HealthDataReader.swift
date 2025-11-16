//
//  HealthDataReader.swift
//  Measurements
//
//  Created by John Matthew Weston on 11/7/25.
//

class HealthDataReader: ObservableObject {

    @Published var sampleSize: Int = 100 {
        didSet {
            retrieveElectrocardiogramTimeSeries()
        }
    }
    @Published var data = [CGFloat]()

    func retrieveElectrocardiogramTimeSeries() {
        data.removeAll()
        HealthDataAdapter.instance.queryECGSamplesForDistantRange(samples: sampleSize ) { [self] result in
            DispatchQueue.main.async {
                //print("RESULT: \(result)")
                let values = Array(result.values)
                for value in values {
                    let element = CGFloat(value)
                    data.append( element )
                }
                print("\(#function): \(data.count) ECG samples received")
            }
        }
    }
}
