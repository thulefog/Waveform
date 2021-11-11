//
//  DataProvider.swift
//
//  Created by John Matthew Weston in February 2015, revised December 2015.
//
//  Copyright © 2015 + 2016 John Matthew Weston. All rights reserved.
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

// MARK: Data Provider based on a concrete [Double] and singleton

public class DataProvider: IDataProvider {
  
    public class var sharedInstance: DataProvider {
        struct Singleton {
            static let instance = DataProvider()
        }
        
        return Singleton.instance
    }
    
    var keyValueStore = [String: [Double] ]()

    var ElementCount: Int {
        return keyValueStore.count
    }
    

    init() {
    }

    public func push(key: String,  values: [Double] ){
        
        if( !keyValueStore.isEmpty && keyValueStore[key] != nil )
        {
            keyValueStore.updateValue(values, forKey: key)
        }
        else
        {
            keyValueStore[key] = values
        }

    }

    public func append(key: String, values: [Double] ) {
        
        if( !keyValueStore.isEmpty && keyValueStore[key] != nil )
        {
            keyValueStore.updateValue(values, forKey: key)
        }
        else
        {
            keyValueStore[key] = values
        }
    }
    
    public func remove(key: String)
    {
        keyValueStore.removeValue( forKey: key )
    }
    
    public var count: Int {
        return keyValueStore.count
    }
    
    public subscript(key: String) -> [Double] {
        return keyValueStore[key]!
    }
}

 

