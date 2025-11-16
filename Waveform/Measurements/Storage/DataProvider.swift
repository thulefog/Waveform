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

