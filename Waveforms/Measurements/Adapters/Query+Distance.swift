//
//  HealthKitDataProvider+HeartRate
//  Measurements
//
//  Created by John Matthew Weston, April 2017.
//
//  Copyright © 2015 - 2017 John Matthew Weston. All rights reserved.
//
//  This code is published under the MIT License.
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
    func dispatchDistanceQueries( retrospectiveTimeIntervalInMonthsFromNow: Int,
        externalHandler: @escaping (String, Double) -> String ) {
        
        DispatchQueue.main.async(execute: {
            () -> Void in
                        
            let endDate = NSDate()
            let comps = NSDateComponents()
            comps.month = -1*retrospectiveTimeIntervalInMonthsFromNow
            let startDate = NSCalendar.current.date( from: comps as DateComponents );
            
            //NB: other fetch methods are HKSampleQuery and not HKStatisticsCollectionQuery
            //removed; the distance measurements provide a more direct metric
            //--> self.fetchStepCountsIntoWeekdayHistogram( endDate, startDate: startDate! )
            self.fetchWalkRunDistanceIntoWeekdayHistogram( endDate: endDate, startDate: startDate! as NSDate, externalHandler: externalHandler )
        })
    }
    
    func fetchStepCounts( endTime: NSDate, startDate: NSDate ) {
        let endDate = NSDate()
        let comps = NSDateComponents()
        comps.month = -6
        let startDate = NSCalendar.current.date( from: comps as DateComponents );

        let stepSampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate as Date, options: [])
        
        let query = HKSampleQuery(sampleType: stepSampleType!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                print("There was an error running the query: \(String(describing: error))")
            }
            
            DispatchQueue.main.async(execute:  {
                for r in results!{
                    let result = r as! HKQuantitySample
                    let quantity = result.quantity
                    let count = quantity.doubleValue(for: HKUnit.count())
                    print("sample: \(count) : step \(result)")
                }
            })
        })
        
        self.healthStore?.execute(query)
    }
  
    func fetchStepCountsIntoWeekdayHistogram( endDate: NSDate, startDate: NSDate ) {
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)

        let interval = NSDateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: NSDate() as Date, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: Calendar(identifier: .gregorian).startOfDay(for: startDate as Date ),
                                                intervalComponents:interval as DateComponents)
        
        var weekDayStepCountHistogram = [String: Double]()
        
        query.initialResultsHandler = { query, results, error in

            if let myResults = results{
                myResults.enumerateStatistics(from: startDate as Date, to: endDate as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let date = statistics.startDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        let dayOfWeekFormatted = dateFormatter.string(from: date)
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        if( !weekDayStepCountHistogram.isEmpty && weekDayStepCountHistogram[dayOfWeekFormatted] != nil )
                        {
                            let currentValue = weekDayStepCountHistogram[dayOfWeekFormatted]
                            let newValue = currentValue! + steps
                            weekDayStepCountHistogram.updateValue( newValue, forKey: dayOfWeekFormatted)
                        }
                        else
                        {
                            weekDayStepCountHistogram[dayOfWeekFormatted] = steps
                        }
                        //print("\(date) |\(dayOfWeekFormatted)| steps |\(steps)|")
                    }
                }
                
                //
                for (weekday, histogramValue) in weekDayStepCountHistogram {
                    print("WEEKDAY |\(weekday)| STEP HISTOGRAM |\(histogramValue)|")
                }
            }
        }
        
        self.healthStore?.execute(query)
    }
    
    func fetchWalkRunDistanceIntoWeekdayHistogram( endDate: NSDate, startDate: NSDate,
        externalHandler: @escaping (String, Double) -> String ) {
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: NSDate() as Date, options: .strictStartDate)
    
        let query = HKStatisticsCollectionQuery(quantityType: type!,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: Calendar(identifier: .gregorian).startOfDay(for: startDate as Date ),
                                                intervalComponents:interval as DateComponents)
        
        var weekDayDistanceHistogram = [String: Double]()
        
        query.initialResultsHandler = { query, results, error in
            if let myResults = results{
                myResults.enumerateStatistics(from: startDate as Date, to: endDate as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let date = statistics.startDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        let dayOfWeekFormatted = dateFormatter.string(from: date)
                        let distance = quantity.doubleValue(for: HKUnit.mile())
                        
                        if( !weekDayDistanceHistogram.isEmpty && weekDayDistanceHistogram[dayOfWeekFormatted] != nil )
                        {
                            let currentValue = weekDayDistanceHistogram[dayOfWeekFormatted]
                            let newValue = currentValue! + distance
                            weekDayDistanceHistogram.updateValue( newValue, forKey: dayOfWeekFormatted)
                        }
                        else
                        {
                            weekDayDistanceHistogram[dayOfWeekFormatted] = distance
                        }
                        //print("\(date) |\(dayOfWeekFormatted)| distance |\(distance)|")
                        
                        //
                    }
                }
                //
                for (weekday, histogramValue) in weekDayDistanceHistogram {
                    print("WEEKDAY |\(weekday)| DISTANCE HISTOGRAM |\(histogramValue)|")
                    let callback = externalHandler( weekday, histogramValue )
                    print("handler: \(callback)")
                }
            }
        }
        
        self.healthStore?.execute(query)
    }	
}
