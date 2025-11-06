//
//  DataProvider.swift
//
//  Created by John Matthew Weston in February 2015, revised December 2015.
//
//  Copyright © 2015 + 2016 John Matthew Weston. All rights reserved.
//
//  This code is licensed under the MIT License.
//  Reference the README and LICENSE files for more detail.
//

import Foundation

// MARK: IDataProvider - CONCRETE

// Data Provider based on a concrete [Double] and singleton

protocol IDataProvider {
    mutating func append(key: String, values: [Double])
    var count: Int { get }
    subscript(key: String) -> [Double] { get }
}

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

// MARK: IGenericDataProvider - GENERIC

protocol IGenericDataProvider {
    associatedtype Element
    mutating func append(key: String, value: Element)
    var count: Int { get }
    subscript(key: String) -> Element { get }
}

public struct GenericDataProvider<Element>: IGenericDataProvider {
    
    var keyValueStore = [String: Element ]()
    
    public mutating func append(key: String, value: Element) {
        self.keyValueStore[key] = value
    }
    
    public var count: Int {
        return keyValueStore.count
    }
    
    public subscript(key: String) -> Element {
        return keyValueStore[key]!
    }
    public init() { }
    
}

