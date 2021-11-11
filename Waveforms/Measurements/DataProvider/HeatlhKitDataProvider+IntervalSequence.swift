//
//  HeatlhKitDataProvider+IntervalSequence.swift
//  Measurements
//
//  Created by John Matthew Weston in November 2017.
//  Copyright © 2017. All rights reserved.
//
//  This code is licensed under the MIT License:
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

extension HealthKitDataProvider
{
    // MARK - Heart Rate Query Day Interval - InterBeatIntervalDataSet typed result
    // EPOCH: 24 Hour Day

    public func fetchHRVSamples( startDate: Date, endDate: Date,
                                 externalHandlerSDNNCallback: @escaping (String, [Double] ) -> Bool ) {
        var sdnnSet = [Double]()
        DispatchQueue.main.async(execute: {
            () -> Void in
            let HRVQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
            
            // Set the Predicates & Interval
            // NOTE: removed options set for HKQueryOptions.strictStartDate; could revisit
            let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [])
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: HRVQuantityType!, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor])
            { (query, samples, error) in
                if(error == nil) {
                    for element in samples!{
                        print("Startdate")
                        print(element.startDate)
                        print(element.sampleType)
                        let sample = element as! HKQuantitySample
                        let quantity = sample.quantity
                        let value = quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                        print( "fetchHRVSamples: ELEMENT \(element) | VALUE \(value)" )
                        print( "fetchHRVSamples: SOURCE \(sample.sourceRevision) | DEVICE \(sample.device)")
                        sdnnSet.append( value )
                    }
                }
                if ((error) != nil) {
                    print( "fetchHRVSamples: HKSampleQuery error \(error!)")
                }
                let callbackResult = externalHandlerSDNNCallback( "SDNN ", sdnnSet )
                print("CALLBACK RESULT: \(callbackResult) ")
            }
            
            self.healthStore?.execute(query)
        })
    }

    
    public func dispatchHeartRateQueryDayIntervals( key: String,
                                                    retrospectiveTimeIntervalInDaysFromNow: Int,
                                                    externalHandlerInterBeatIntervals: @escaping (String, InterBeatIntervalSequence ) -> Bool )
    {
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
                                            externalHandlerInterBeatIntervals: @escaping (String, InterBeatIntervalSequence ) -> Bool )
    {
        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        var sampleSet = [String: Double]()
        
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
}

