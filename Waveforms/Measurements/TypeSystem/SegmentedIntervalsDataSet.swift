//
//  SegmentIntervalsDataSet.swift
//  Measurements
//
//  Created by John Matthew Weston in July 2017.
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

public class SegmentedIntervalsDataSet
{
    let RETROSPECTIVE_SEGMENT_DURATION = -300
    let PROSPECTIVE_SEGMENT_DURATION = 300
    let NUMBER_OF_SEGMENTS = 288
    let RETROSPECTIVE_DAY_IN_MILLISECONDS = -86400
    
    var _key: String
    
    public var _startDate: String
    public var _endDate: String
    public var _timeInterval: Int
    
  
    public var _SDNNIndex : Double?
    public var _SDANN : Double?
    
    // MARK - Heart Rate Query Day Interval - SegmentedIntervalsDataSet typed result
    // EPOCH: Epoch: 24 Hour Day - 5 Minute Segments (288)

    public init( key: String, description: String,
                 startDate: Date, endDate: Date,
                 interBeatIntervals: InterBeatIntervalSequence )
    {
        _key = key
        
        _startDate = startDate.toString(dateFormat: "YYYY-MM-dd-HH:mm:ss")
        _endDate = endDate.toString(dateFormat: "YYYY-MM-dd-HH:mm:ss")
        
        let dateInterval = DateInterval( start: startDate, end: endDate )
        let timeInterval = TimeInterval( RETROSPECTIVE_DAY_IN_MILLISECONDS )
        _timeInterval = Int(timeInterval)

        var trace = "dateInterval: \(dateInterval) | timeInterval: \(timeInterval)"
        print( trace )
        
        let segments = calculateSegments( trailingEdgeAnchorDate: endDate )
        
        //let segmentIndex = determineSegmentIndex( segments: segments, dateTimeValue: testProbeDateValue )
        
        //_beatPerMinuteSegmentIndexed = Dictionary(minimumCapacity: segmentCount )
        
    
        var segmentSinks = [Int:Array<InterBeatIntervalElement>]()
        
        let intervalSampleSetSize = interBeatIntervals._interBeatIntervalSampleSet.count
        
        for sampleIndex in 0...intervalSampleSetSize-1 {
        
            let leadingEdgeSegmentResult = determineSegmentIndex( segments: segments, dateTimeValue: interBeatIntervals._interBeatIntervalSampleSet[sampleIndex].startDate )
            let trailingEdgeSegmentResult = determineSegmentIndex( segments: segments, dateTimeValue: interBeatIntervals._interBeatIntervalSampleSet[sampleIndex].endDate )

            trace = "SAMPLE | \(sampleIndex) : START \(interBeatIntervals._interBeatIntervalSampleSet[sampleIndex].startDate) END \(interBeatIntervals._interBeatIntervalSampleSet[sampleIndex].endDate)"
            print( trace )
            
            trace = "SAMPLE | \(sampleIndex) : LEAD \(leadingEdgeSegmentResult) TRAIL \(trailingEdgeSegmentResult)"
            print( trace )
            
            //NOTE: seems redundant to capture another copy of sample in collection for epoch
            //if( leadingEdgeSegmentResult == traiingEdgeSegmentResult ) { segmentSinks.append ... }
            
        }
        _SDANN = 0.0
        _SDNNIndex =  0.0
    }
    
    func calculateSegments( trailingEdgeAnchorDate: Date ) ->  [Int:Array<Date>]
    {
        var trace = "calculateSegments - reference point  trailingEdgeAnchorDate: \(trailingEdgeAnchorDate)"
        print( trace )
        
        var segments = [Int:Array<Date>]()
        //NOTE: this syntax does not work ---> var segments [Int:[Date]] = [:]
        
        // Approach:
        // Trailing Edge : typically be date/time now to do retrospective analysis
        // Leading Edge  : calculated back as function of epochs relative to trailing edge
        // d             : time duration of 5 minutes per epoch
        // S(i)          : segment at index i; for 24 hour day that equals total N=288
        //
        //
        //  |<-d->|
        //  [ S0  ][ S1  ]    ..... [ S(i) ][ S(N) ]
        //  ^---Leading Edge  .... Trailing Edge---^
        let timeIntervalLeadingEdgeAnchor = TimeInterval( RETROSPECTIVE_SEGMENT_DURATION*NUMBER_OF_SEGMENTS )
        let dateLeadingEdgeAnchor = Date( timeInterval: timeIntervalLeadingEdgeAnchor, since: trailingEdgeAnchorDate as Date )
        
        for segmentIndex in 0...NUMBER_OF_SEGMENTS-1 {
            
            // 300 seconds = 60 seconds/min * 5 min
            //NOTE: the -1 should make the dynamic interval and thus date square up with leading edge - dateLeadingEdgeAnchor
            let timeIntervalLeading = TimeInterval( PROSPECTIVE_SEGMENT_DURATION*(segmentIndex-1) )
            let segmentLeadingEdgeDate = Date( timeInterval: timeIntervalLeading, since: dateLeadingEdgeAnchor as Date )
            
            let timeIntervalTrailing = TimeInterval( PROSPECTIVE_SEGMENT_DURATION*(segmentIndex) )
            let segmentTrailingEdgeDate = Date( timeInterval: timeIntervalTrailing, since: dateLeadingEdgeAnchor as Date )
            
            trace = "Segmented \(segmentIndex): segmentLeadingEdgeDate: \(segmentLeadingEdgeDate) segmentTrailingEdgeDate: \(segmentTrailingEdgeDate)"
            print( trace )
            
            //TODO: refactor into a type, for now indices
            var sampleInterval: [Date] = [segmentLeadingEdgeDate, segmentTrailingEdgeDate]
            segments[segmentIndex] = sampleInterval
            
        }
        
        for segmentIndex in 1...NUMBER_OF_SEGMENTS {
            trace = "SEGMENT | \(segmentIndex) | \(String(describing: segments[segmentIndex]?[0])) | \(String(describing: segments[segmentIndex]?[1]))"
            print( trace )
        }
        return segments
    }
    
    func determineSegmentIndex( segments: [Int:Array<Date>], dateTimeValue: Date ) -> Int
    {
        var trace = "determineSegmentIndex: searching for segment containing \(dateTimeValue)"
        print( trace )
        
        var result = -1
        //for test purposes, shorten test time via narrowed search; adjust loop start to use scalar applied to expectedIndex -->( NUMBER_OF_SEGMENTS - 2*expectedIndex)...
        for segmentIndex in (0...NUMBER_OF_SEGMENTS-1) {
            // use of > or < did not work...
            let leadingResult = dateTimeValue.compare( segments[segmentIndex]![0] )
            let trailingResult = dateTimeValue.compare( segments[segmentIndex]![1] )

            trace = "determineSegmentIndex: input: \(dateTimeValue) | \(segments[segmentIndex]![0]) | \(segments[segmentIndex]![1])"
            print( trace )
            trace = "determineSegmentIndex: comparions results: \(segmentIndex) | LEAD/rawValue \(leadingResult.rawValue) | TRAIL/rawValue \(trailingResult.rawValue)"
            print( trace )
            
            if( leadingResult.rawValue == 1 && //ComparisonResult.orderedAscending
                trailingResult.rawValue == -1 ) //expected 0 (ComparisonResult.orderedDescending) but hueristically -1 returned...
            {
                trace = "determineSegmentIndex: RESULT: VALUE \(dateTimeValue) at INDEX \(segmentIndex) **IN RANGE** { \(String(describing: segments[segmentIndex]?[0])) ... \(String(describing: segments[segmentIndex]?[1])) }"
                print( trace )
                result = segmentIndex
            }
        }
        return result
    }
}
