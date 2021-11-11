//
//  HeartRateSampleSequence.swift
//  Measurements
//
//  Created by John Matthew Weston on 5/6/17.
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
import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

public func convertHeartRateToInterbeatInterval( heartRateBeatsPerMinute: Double ) -> Double
{
    var normalToNormalIntervalValue = Double( 60000.0 / heartRateBeatsPerMinute )
    return normalToNormalIntervalValue
}

public struct HeartRateSampleElement {
    public var description: String
    
    public var startDate: Date
    public var endDate: Date
    
    public var beatsPerMinute: Double
    
    public init( description:  String, startDate: Date, endDate: Date, beatsPerMinute: Double )
    {
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        
        self.beatsPerMinute = beatsPerMinute
    }
}

// Refactored struct interface to enable JSON serialization: 
// - all fields are primitive types
// - all fields are not optional
//
// public struct HeartRateSampleSequence : JSONSerializable
// public var startDate: String
// public var endDate: String
// ...Date.toString(dateFormat: "YYYY-MM-dd-HH:mm:ss")
//..
//if let json = interval._heartRateDataSet.toJSON()
//{
//   print( "JSON: \(json)" )
//}

public struct HeartRateSampleSequence  {
    public var description: String

    public var startDate: Date
    public var endDate: Date
    
    public var beatPerMinuteSampleSet = [HeartRateSampleElement]()

    public var _minimum = Double()
    public var _maximum = Double()
    public var _average = Double()
    public var _minMaxWindow = Double()
    public var _standardDeviation : Double?
    
    public init( description:  String, startDate: Date, endDate: Date )
    {
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public init( description:  String, startDate: Date, endDate: Date, beatPerMinuteSampleSet: [HeartRateSampleElement] )
    {
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.beatPerMinuteSampleSet = beatPerMinuteSampleSet
        
        let bpmMap = self.beatPerMinuteSampleSet.map{  $0.beatsPerMinute }
        
        _minimum = bpmMap.min()!
        _maximum = bpmMap.max()!
        _minMaxWindow = _maximum - _minimum
        _average = bpmMap.reduce(0, {$0 + $1}) / Double( bpmMap.count)
        
        let sumOfSquaredAvgDiff = bpmMap.map { pow($0 - _average, 2.0)}.reduce(0, {$0 + $1})
        _standardDeviation = sqrt(sumOfSquaredAvgDiff / Double(bpmMap.count) )
    }
}


