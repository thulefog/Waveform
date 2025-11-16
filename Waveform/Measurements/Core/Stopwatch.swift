//
//  Stopwatch
//  Measurements
//
//  Stopwatch - a simplistic approach to instrument code to measure performance 
//
//  Copyright © 2015-2017 John Matthew Weston. All rights reserved.
//
//  This code is licensed under the MIT License.
//  Reference the README and LICENSE files for more detail.
//

import Foundation

public class Stopwatch {
    public init() { }
    private var _start: TimeInterval = 0.0;
    private var _end: TimeInterval = 0.0;
    
    public func start() {
        _start = NSDate().timeIntervalSince1970;
    }
    
    public func stop() {
        _end = NSDate().timeIntervalSince1970;
    }
    
    public func durationSeconds() -> TimeInterval {
        return _end - _start;
    }
}
