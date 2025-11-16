//
//  AlgorithmAdapter.swift
//  Measurements
//
//  Created by John Matthew Weston on 10/17/21.
//
//  This code is licensed under the MIT License.
//  Reference the README and LICENSE files for more detail.
//
import Foundation

extension UnsafeMutablePointer {
    func toArray(capacity: Int) -> [Pointee] {
        return Array(UnsafeBufferPointer(start: self, count: capacity))
    }
}

/*
 var input: [Float]
 input = [3.9, 7.7, 11.1, 1.11, 1.02, 3.3, 3.9, 0]
...
 let algorithms = AlgorithmAdapter()
 _ = algorithms.execute( inputArray: input )

 */
struct AlgorithmAdapter {
    
    func convertArrayData<T>(count: Int, data: UnsafePointer<T>) -> [T] {

        let buffer = UnsafeBufferPointer(start: data, count: count)
        return Array(buffer)
    }
    
    public func execute( inputArray: [Float] ) -> [Float] {
        var outputArray: [Float] = Array(repeating: 0, count: inputArray.count)
        let bridgeInstance = BridgedPort()

        bridgeInstance.processDataOuter(inputArray, andLength: inputArray.count, output: &outputArray)
        print("\(#function): input: \(inputArray) output \(outputArray)")
        return outputArray
    }
}
