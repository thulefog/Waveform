//
//  HealthKitDataProvider+HeartRate
//  Measurements
//
//  Created by John Matthew Weston, April 2017.
//
//  Copyright © 2015 - 2017 John Matthew Weston. All rights reserved.
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
    func fetchWeightSamples() {
        let endDate = NSDate()
        let comps = NSDateComponents()
        comps.month = -2
        
        let startDate = NSCalendar.current.date( from: comps as DateComponents );
        
        let weightSampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate as Date, options: [])
        
        let query = HKSampleQuery(sampleType: weightSampleType!, predicate: predicate,
            limit: 0, sortDescriptors: nil, resultsHandler: {
                (query, results, error) in
                if results == nil {
                    print("There was an error running the query: \(String(describing: error))")
                }
                DispatchQueue.main.async() {
                    
                    for r in results!{
                        let result = r as! HKQuantitySample
                        let quantity = result.quantity
                        print("sample: \(quantity) : weight \(result)")
                    }

                }
        })
        self.healthStore?.execute(query)
    }
}
