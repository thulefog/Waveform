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

extension HealthDataAdapter
{
    // MARK - Heart Rate Query Day Interval - InterBeatIntervalDataSet typed result
    // EPOCH: 24 Hour Day

    public func fetchHRVSamples( startDate: Date, endDate: Date,
                                 callback: @escaping (String, [Double] ) -> Bool ) {
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
                        print( "\(#function): ELEMENT \(element) | VALUE \(value)" )
                        print( "\(#function): SOURCE \(sample.sourceRevision) | DEVICE \(String(describing: sample.device))")
                        sdnnSet.append( value )
                    }
                }
                if ((error) != nil) {
                    print( "\(#function): HKSampleQuery error \(error!)")
                }
                let callbackResult = callback( "SDNN ", sdnnSet )
                print("CALLBACK RESULT: \(callbackResult) ")
            }
            
            self.healthStore?.execute(query)
        })
    }
}

