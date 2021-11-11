//
//  HealthKitDataProvider+AnchorStream.swift
//  Measurements
//
//  Created by John Matthew Weston in December 2017.
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
    
    // MARK - Anchored query approach

    public func dispatchAnchoredQuery(_ startDate : Date, endDate: Date ) {
        
        var heartRateQuery: HKQuery?
        
        if let query = createHeartRateAnchoredQuery( startDate, endDate: endDate ) {
            heartRateQuery = query
            healthStore?.execute(query)
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
}
