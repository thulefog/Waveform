//
//  HealthKitDataProvider+HeartRate
//  Measurements
//
//  Created by John Matthew Weston, April 2017.
//  Copyright © 2015 - 2017 John Matthew Weston. All rights reserved.
//
//  This code is published under the MIT License.
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
import HealthKit
import UIKit

extension HealthDataAdapter
{
    
    // MARK - HKSampleQuery worker methods
    public func printHeartRateSample(data:HKQuantitySample?) {
        guard let sample:HKQuantitySample = data else {
            print ( "Error: invalid parameter passed" )
            return
        }
        
        //? --->
        
        /* Example output.
         NB that code flow in Swift <3 that handled HKUnit.heartBeatsPerMinuteUnit not in play now
         -
         Heart Rate: 1.66666666666667
         quantityType: HKQuantityTypeIdentifierHeartRate
         Start Date: 2017-04-30 03:45:36 +0000
         End Date: 2017-04-30 03:45:36 +0000
         Metadata: nil
         UUID: 0426EA35-0990-44A4-8D94-F2D76E347D2B
         Source: <<HKSourceRevision: 0x174225360>, name:John's Apple Watch, bundle:com.apple.health.A2DEBCF0-376A-404F-AF83-F07E1008BF32, version:3.1.3>
         Device: Optional(<<HKDevice: 0x174094be0>, name:Apple Watch, manufacturer:Apple, model:Watch, hardware:Watch1,2, software:3.1.3>)
         -
         */
        
        print("-")
        print("HeartRate: \(sample.quantity.doubleValue(for: HKUnit(from: "count/s") ) )")
        print("QuantityType: \(sample.quantityType)")
        print("StartDate: \(sample.startDate)")
        print("EndDate: \(sample.endDate)")
        print("Metadata: \(String(describing: sample.metadata))")
        print("UUID: \(sample.uuid)")
        print("Source: \(sample.sourceRevision)")
        print("Device: \(String(describing: sample.device))")
        print("-")
    }
    
    // MARK - Heart Rate Query Day Interval - simple typed result
    
    public func dispatchHeartRateQueryDay( key: String,
                                           retrospectiveTimeIntervalInDaysFromNow: Int,
                                           externalHandlerBeatsPerMinute: @escaping (String, HeartRateSampleSequence ) -> Bool ) {
        DispatchQueue.main.async(execute: {
            () -> Void in
            
            print( "dispatchHeartRateQueryDay(): FETCH key \(key)" )
            
            let endDate = Date()
            let timeInterval = TimeInterval( -86400*retrospectiveTimeIntervalInDaysFromNow )
            let startDate = Date( timeInterval: timeInterval, since: endDate as Date  )
            
            print( "startDate: \(startDate) endDate: \(endDate)" )
            self.fetchHeartRates( key: key, startDate: startDate, endDate: endDate,
                                  externalHandlerBeatsPerMinute: externalHandlerBeatsPerMinute )
        })
    }
    
    func fetchHeartRates( key: String,
                          startDate: Date, endDate: Date,
                          externalHandlerBeatsPerMinute: @escaping (String, HeartRateSampleSequence)  -> Bool) {
        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        var sampleSet = [String: Double]()
        
        var beatsPerMinuteSet = [HeartRateSampleElement]()
        
        print( "fetchHeartRates() ENTER: FETCH key \(key)" )
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: Int(HKObjectQueryNoLimit)/*100*/, sortDescriptors: [sortDescriptor])
        { (query, samples, error) in
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
            } else {
                for element in samples!{
                    let sample = element as! HKQuantitySample
                    let quantity = sample.quantity
                    
                    /*
                     Heuristically:
                     
                     HR: 100.0 : sample: 1.66667 count/s 0426EA35-0990-44A4-8D94-F2D76E347D2B "John's Apple Watch" (3.1.3) "Apple Watch"  (2017-04-29 20:45:36 -0700 - 2017-04-29 20:45:36 -0700)
                     R-R Interval: 600.0
                     */
                    
                    let heartRateValue = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    //NB: scalar applied to calculate R-R depends on how sample extacted;
                    //BPM fetched using count/min would be 60000 = (1000 ms/sec * 60 sec/min ) to reach R-R interval [ms]
                    let normalToNormalIntervalValue = convertHeartRateToInterbeatInterval( heartRateBeatsPerMinute: heartRateValue )
                    
                    print("_")
                    print("HR: \(heartRateValue) : sample: \(sample)")
                    print("R-R Interval: \(normalToNormalIntervalValue)")
                    
                    self.printHeartRateSample( data: sample )
                    
                    print("uuid: \(sample.uuid) | BPM: \(heartRateValue) | RR Interval [ms]: \(normalToNormalIntervalValue) ")
                    print("_")
                    
                    let sampleElement = HeartRateSampleElement( description: sample.uuid.uuidString,
                                                                startDate: sample.startDate, endDate: sample.endDate,
                                                                beatsPerMinute: heartRateValue )
                    beatsPerMinuteSet.append(sampleElement)
                    
                    if( !sampleSet.isEmpty && sampleSet[sample.uuid.uuidString] != nil )
                    {
                        print( "Warning: Key \(sample.uuid) contains Value \(String(describing: sampleSet[sample.uuid.uuidString]))")
                    }
                    else
                    {
                        print( "Capturing key/value in set" )
                        sampleSet[sample.uuid.uuidString] = heartRateValue
                        
                        //NOTE
                        // This callback trigger can be done for each sample and might make sense for a "real time" graphing flow
                        // Instead, there is one update to trigger graphing or algorithm calculation step, see below
                        
                    }
                }
                let heartRateSampleSequence = HeartRateSampleSequence(  description:key,
                                                                        startDate: startDate, endDate: endDate,
                                                                        beatPerMinuteSampleSet: beatsPerMinuteSet )
                
                let callbackResultBeatsPerMinute = externalHandlerBeatsPerMinute( key, heartRateSampleSequence )
                
                print("CALLBACK RESULT: \(callbackResultBeatsPerMinute)")
            }
        }
        self.healthStore?.execute(query)
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        //inefficent: move
        let heartRateUnit = HKUnit(from: "count/min")
        
        guard let heartRateSamples = samples as? [HKQuantitySample] else {
            return
        }
        guard let sample = heartRateSamples.first else {
            return
        }
        let value = sample.quantity.doubleValue(for: heartRateUnit)
        let hr = String(UInt16(value))
        
        print(" ms - ", hr, " bpm")
    }
    
    public func dispatchHeartRateQueryDayIntervals( key: String,
                                                    retrospectiveTimeIntervalInDaysFromNow: Int,
                                                    externalHandlerInterBeatIntervals: @escaping (String, InterBeatIntervalSequence ) -> Bool ) {
        DispatchQueue.main.async(execute: {
            () -> Void in
            
            print( "dispatchHeartRateQueryDayInterval(): FETCH key \(key)" )
            
            let endDate = Date()
            let timeInterval = TimeInterval( -86400*retrospectiveTimeIntervalInDaysFromNow )
            let startDate = Date( timeInterval: timeInterval, since: endDate as Date  )
            
            print( "startDate: \(startDate) endDate: \(endDate)" )
            self.fetchHeartRatesReturnDayIntervals( key: key, startDate: startDate, endDate: endDate,
                                                    externalHandlerInterBeatIntervals: externalHandlerInterBeatIntervals )
            
        })
    }
    
    func fetchHeartRatesReturnDayIntervals( key: String,
                                            startDate: Date, endDate: Date,
                                            externalHandlerInterBeatIntervals: @escaping (String, InterBeatIntervalSequence ) -> Bool ) {
        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        _ = [String: Double]()
        
        var interBeatIntervalSampleSet = InterBeatIntervalSampleSet()
        
        var beatsPerMinuteSet = [Double]()
        
        print( "fetchHeartRatesReturnDayIntervals() ENTER: FETCH key \(key)" )
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: Int(HKObjectQueryNoLimit)/*100*/, sortDescriptors: [sortDescriptor])
        { (query, samples, error) in
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
            } else {
                for element in samples!{
                    let sample = element as! HKQuantitySample
                    let quantity = sample.quantity
                    
                    /*
                     Heuristically:
                     
                     HR: 100.0 : sample: 1.66667 count/s 0426EA35-0990-44A4-8D94-F2D76E347D2B "John's Apple Watch" (3.1.3) "Apple Watch"  (2017-04-29 20:45:36 -0700 - 2017-04-29 20:45:36 -0700)
                     R-R Interval: 600.0
                     */
                    
                    let beatsPerMinuteSample = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    //NB: scalar applied to calculate R-R depends on how sample extacted;
                    //BPM fetched using count/min would be 60000 = (1000 ms/sec * 60 sec/min ) to reach R-R interval [ms]
                    let normalToNormalIntervalValue = convertHeartRateToInterbeatInterval( heartRateBeatsPerMinute: beatsPerMinuteSample )
                    
                    print("_")
                    print("HR: \(beatsPerMinuteSample) : sample: \(sample)")
                    print("RR Interval: \(normalToNormalIntervalValue)")
                    
                    self.printHeartRateSample( data: sample )
                    
                    print("uuid: \(sample.uuid) | BPM: \(beatsPerMinuteSample) | RR Interval [ms]: \(normalToNormalIntervalValue) ")
                    print("_")
                    
                    //OLD
                    beatsPerMinuteSet.append(beatsPerMinuteSample)
                    
                    //NEW
                    let interBeatIntervalElement = InterBeatIntervalElement( description: sample.uuid.uuidString,
                                                                             startDate: sample.startDate, endDate: sample.endDate,
                                                                             normalToNormalIntervalSample: normalToNormalIntervalValue )
                    
                    //NB: simple append plus a reverse would be needed to preserve the timeline order; instead insert at startIndex
                    interBeatIntervalSampleSet.insert( interBeatIntervalElement, at: interBeatIntervalSampleSet.startIndex )
                }
                
                let endDate = Date()
                let timeInterval = TimeInterval( -86400 )
                let startDate = Date( timeInterval: timeInterval, since: endDate as Date )
                let describe = "startDate: \(startDate) endDate: \(endDate)"
                
                if( samples?.count == 0 )
                {
                    print( "GUARD: fetchHeartRates - zero samples [Double] from HKSampleQuery")
                    //OPEN: throw?
                    return
                }
                
                let interBeatIntervalSequence = InterBeatIntervalSequence( key: key, description: describe,
                                                                           startDate: startDate, endDate: endDate,
                                                                           interBeatIntervalSampleSet: interBeatIntervalSampleSet )
                
                let callbackResultInterBeatInterval = externalHandlerInterBeatIntervals( key, interBeatIntervalSequence )
                print("CALLBACK RESULT: \(callbackResultInterBeatInterval) ")
                
            }
        }
        self.healthStore?.execute(query)
    }
    
    public func dispatchAnchoredQuery(_ startDate : Date, endDate: Date ) {
        if let heartRateQuery = createHeartRateAnchoredQuery( startDate, endDate: endDate ) {
            healthStore?.execute(heartRateQuery)
        } else {
            print("Error: failed to create and execute heart rate query.")
        }
    }
    
    func createHeartRateAnchoredQuery(_ startDate: Date, endDate: Date) -> HKQuery? {
        guard let heartRateQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return nil
        }
        // NOTE: for this file name the Anchor is a reference to being anchored to a start date
        //       setting endDate to nil makes this a *streaming* query.
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateQuantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateHeartRate(sampleObjects)
        }
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
}
