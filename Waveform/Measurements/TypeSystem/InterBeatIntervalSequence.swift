//
//  InterBeatIntervalSequence.swift
//  Measurements
//
//  Created by John Matthew Weston in July 2017.
//  Copyright © 2017. All rights reserved.
//

import Foundation

// HRV parameters are calculated on ‘Normal-to-Normal’ (NN) inter-beat intervals (or NN intervals)
// caused by normal heart contractions paced by sinus node depolarization.

public struct InterBeatIntervalElement {
    public var description: String
    
    public var startDate: Date
    public var endDate: Date
    
        //OPEN: could hold one collection for BPM || RR dynamically and back/forward calculate (convertHeartRateToInterbeatInterval)
    public var normalToNormalIntervalSample: Double
    
    public init( description:  String, startDate: Date, endDate: Date, normalToNormalIntervalSample: Double )
    {
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        
        self.normalToNormalIntervalSample = normalToNormalIntervalSample
    }
}

public typealias InterBeatIntervalSampleSet = Array<InterBeatIntervalElement>

public class InterBeatIntervalSequence
{
    var _key: String
    
    public var _interBeatIntervalSampleSet = InterBeatIntervalSampleSet()
    
    public var _minimum = Double()
    public var _maximum = Double()
    public var _average = Double()
    public var _minMaxWindow = Double()
    public var _standardDeviation : Double?
    public var _rmssd : Double?
    public var _lnrmssd : Double?
    public var _SDNN : Double?
    // effectively Standard Deviation in classical sense but a NN specifc measure
    public var _NN50 = Int()
    public var _pNN50 : Double?
    
    public init( key: String, description: String, startDate: Date, endDate: Date, interBeatIntervalSampleSet: InterBeatIntervalSampleSet )
    {
        _key = key
        var timeInterval = TimeInterval()
        timeInterval = startDate.timeIntervalSince( _ : endDate )
        
        _ = startDate.toString(dateFormat: "YYYY-MM-dd-HH:mm:ss")
        _ = endDate.toString(dateFormat: "YYYY-MM-dd-HH:mm:ss")
        _ = Int(timeInterval)
        
        self._interBeatIntervalSampleSet = interBeatIntervalSampleSet
        
        if( _interBeatIntervalSampleSet.count == 0 )
        {
            print( "GUARD: InterBeatIntervalDataSet ctor - zero samples in InterBeatIntervalSequence")
            //OPEN: throw?
            return
        }
        
        let rrIntervalMap = self._interBeatIntervalSampleSet.map{  $0.normalToNormalIntervalSample }
        
        _minimum = rrIntervalMap.min()!
        _maximum = rrIntervalMap.max()!
        _minMaxWindow = _maximum - _minimum
        _average = rrIntervalMap.reduce(0, {$0 + $1}) / Double( rrIntervalMap.count)
        
        let sumOfSquaredAvgDiff = rrIntervalMap.map { pow($0 - _average, 2.0)}.reduce(0, {$0 + $1})
        
        _standardDeviation = sqrt(sumOfSquaredAvgDiff / Double(rrIntervalMap.count) )
        _SDNN = _standardDeviation
        
        rootMeanSquareOfSuccessiveDifferences()
        thresholdNearNeighborDifferences()
        
        describe()
    }
    
    public func standardDeviation( sampleSet: [Double] ) -> Double
    {
        let sumOfSquaredAvgDiff = sampleSet.map { pow($0 - _average, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / Double(sampleSet.count) )
    }
    
    public func average(sampleSet:[Double]) -> Double {
        return Double(sampleSet.reduce(0,+))/Double(sampleSet.count)
    }
    
    //MARK: Interval Difference Measures: rMSSD and nn50.
    
    //These Interval Difference Measures - rMSSD and nn50 - could be refactored into a subclass; minimizing moving parts for now.
    func rootMeanSquareOfSuccessiveDifferences()
    {
        var ssd = [Double]()
        
        if( _interBeatIntervalSampleSet.count < 2 )
        {
            print( "Warning: Number of data samples is insufficent to calculate rMSSD \(_interBeatIntervalSampleSet.count)")
            return
        }
        for intervalIndex in 1...(_interBeatIntervalSampleSet.count-1)
        {
            let intervalDelta  = abs(_interBeatIntervalSampleSet[intervalIndex].normalToNormalIntervalSample -
                _interBeatIntervalSampleSet[intervalIndex-1].normalToNormalIntervalSample)
            print( "RR Interval Delta [\(intervalIndex)] = [ms] \(intervalDelta)" )
            
            ssd.append( pow(intervalDelta,2) )
        }
        let mssd = average( sampleSet: ssd )
        _rmssd = Double(sqrt(mssd))
        
        _lnrmssd = log( _rmssd! )
        
        print("-")
        print("Average of SSD: \(mssd)" )
        print("RMSSD: \(String(describing: self._rmssd))" )
        print("ln(RMSSD): \(String(describing: self._lnrmssd))" )
        print("-")
    }
    
    func thresholdNearNeighborDifferences()
    {
        if( _interBeatIntervalSampleSet.count < 2 )
        {
            print( "Warning: Number of R-R data samples is insufficent to calculate nn50 \(_interBeatIntervalSampleSet.count)")
            return
        }
        //this is a set of calculations that is logical to centralize in one method
        //- determine number of interval deltas > 50
        //- determine precentage of NN50 against all RR interval
        for intervalIndex in 1...(_interBeatIntervalSampleSet.count-1)
        {
            let intervalDelta  = abs(_interBeatIntervalSampleSet[intervalIndex].normalToNormalIntervalSample -
                _interBeatIntervalSampleSet[intervalIndex-1].normalToNormalIntervalSample)
            print( "| RR<i> - RR<i-1> | = [ms] \(intervalDelta) at index [\(intervalIndex)] " )
        
            if( intervalDelta > 50 )
            {
                _NN50 += 1
            }
        }
        
        do {
            if( _NN50 > 0 ) {
                _pNN50 = ( Double(_NN50) * 100) / Double( _interBeatIntervalSampleSet.count - 1)
            }
            else {
                _pNN50 = 0.0
            }
        }
    }
    
    func describe()
    {
        print("-")
        print("Normal-Normal (N-N) or R-R Interval Measures:")
        print("-")
        
        print("StandardDeviation: \(_standardDeviation!)")
        print("Minimum: \(_minimum)")
        print("Maximum: \(_maximum)")
        print("Average: \(_average)")
        print("Min/Max Window \(_minMaxWindow)")
        
        print("-")
    }
}


