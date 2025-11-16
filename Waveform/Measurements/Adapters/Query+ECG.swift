//
//  HealthKitDataProvider+ECG.swift
//  Measurements
//
//  Created by John Matthew Weston on 10/17/21.
//
//  This code is licensed under the MIT License.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
import Foundation

import HealthKit

extension HealthDataAdapter {
        
    public typealias carteisanTimeSeries = [Double : Double]

    public func queryElectorcardiogramSamples(  ) {
        // Create the electrocardiogram sample type.
        let ecgType = HKObjectType.electrocardiogramType()

        // Query for electrocardiogram samples
        let ecgQuery = HKSampleQuery(sampleType: ecgType,
                                     predicate: nil,
                                     limit: HKObjectQueryNoLimit,
                                     sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                // Handle the error here.
                fatalError("*** An error occurred \(error.localizedDescription) ***")
            }
            
            guard let ecgSamples = samples as? [HKElectrocardiogram] else {
                fatalError("*** Unable to convert \(String(describing: samples)) to [HKElectrocardiogram] ***")
            }
            
            for sample in ecgSamples {
                // Handle the samples here.
                print( "\(#function): SAMPLE: \(sample)" )
            }
        }

        // Execute the query.
        self.healthStore?.execute(ecgQuery)
    }
        
    public func queryECGSamplesForDistantRange(samples: Int, completion: @escaping (carteisanTimeSeries) -> ()  )   {
        var timeSeries = [Double:Double]()

         if #available(iOS 14.0, *) {
                 let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,end: Date.distantFuture,options: .strictEndDate)
                 let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                 let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(),
                                              predicate: predicate,
                                              limit: samples,
                                              sortDescriptors: [sortDescriptor]){ (query, samples, error) in
                     guard let samples = samples,
                         let mostRecentSample = samples.first as? HKElectrocardiogram else {
                         return
                     }
                     print(mostRecentSample)
                     var ecgSamples = [(Double,Double)] ()
                     let query = HKElectrocardiogramQuery(mostRecentSample) { (query, result) in
                         
                         switch result {
                         case .error(let error):
                             let message = "\(#function): Error: \(error)"
                             print("\(message)")
                             fatalError( message )
                             
                         case .measurement(let value):
                             //print("\(#function): MEASUREMENT: ", value)
                             let sample = (value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt()) , value.timeSinceSampleStart)
                             ecgSamples.append(sample)
                           
                             //swizzle the tuple into the published result
                             timeSeries[sample.1] = sample.0
                             print("\(#function): SAMPLE: \(sample.1) [sec]  = \(sample.0) [volt]")

                         case .done:
                             print("\(#function): HKElectrocardiogramQuery: done")
                             completion(timeSeries )
                         @unknown default:
                             fatalError("Fatal error handling unknown result case")
                         }
                     }
                     self.healthStore?.execute(query)
                 }
                 healthStore?.execute(ecgQuery)
             } else {
                 // Fallback on earlier versions
             }
    }
    
    public func queryECGSamplesForRange(  )  {
        _ = [Double:Double]()

         if #available(iOS 14.0, *) {
                 let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,end: Date.distantFuture,options: .strictEndDate)
                 let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                 let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]){ (query, samples, error) in
                     guard let samples = samples,
                         let mostRecentSample = samples.first as? HKElectrocardiogram else {
                         return
                     }
                     print(mostRecentSample)
                     var ecgSamples = [(Double,Double)] ()
                     let query = HKElectrocardiogramQuery(mostRecentSample) { (query, result) in
                         
                         switch result {
                         case .error(let error):
                             let message = "\(#function): Error: \(error)"
                             print("\(message)")
                             fatalError( message )
                             
                         case .measurement(let value):
                             //print("\(#function): MEASUREMENT: ", value)
                             let sample = (value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt()) , value.timeSinceSampleStart)
                             ecgSamples.append(sample)
                           
                             print("\(#function): SAMPLE: \(sample.1) [sec]  = \(sample.0) [volt]")

                         case .done:
                             print("\(#function): HKElectrocardiogramQuery: done")

                         @unknown default:
                             fatalError("Fatal error handling unknown result case")
                         }
                     }
                     self.healthStore?.execute(query)
                 }
                 healthStore?.execute(ecgQuery)
             } else {
                 // Fallback on earlier versions
             }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {

        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            self.process(samples, type: quantityTypeIdentifier)
        }
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        self.healthStore?.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        let heartRateQuantity = HKUnit(from: "count/min")

        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            print( "lastHeartRate: \(lastHeartRate)" )
            //self.value = Int(lastHeartRate)
        }
    }
    
    func queryAverageHeartRate() {
        let calendar = Calendar.current
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        // Start 14 days back, end with today
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -14, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        // Set the anchor to exactly midnight
        let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        
        // Generate daily statistics
        var interval = DateComponents()
        interval.day = 1
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: heartRateType,
                                                quantitySamplePredicate: predicate,
                                                options: .discreteAverage,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else { return }
            
            for statistics in statsCollection.statistics() {
                guard let quantity = statistics.averageQuantity() else { continue }
                
                let beatsPerMinuteUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = quantity.doubleValue(for: beatsPerMinuteUnit)
                
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                print("DATE \(df.string(from: statistics.startDate)) the average heart rate was \(value) beats per minute")
            }
        }
        
        HKHealthStore().execute(query)
    }
    
}

