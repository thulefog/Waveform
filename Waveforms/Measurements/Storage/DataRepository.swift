//
//  DataRepository.swift
//  Waveformus
//
//  Created by John Matthew Weston on 11/6/25.
//
//  This code is licensed under the MIT License.
//  Reference the README and LICENSE files for more detail.
//

// MARK: IDataProvider - CONCRETE

// Data Provider based on a concrete [Double] and singleton

protocol IDataProvider {
    mutating func append(key: String, values: [Double])
    var count: Int { get }
    subscript(key: String) -> [Double] { get }
}

public class DataRepository: IDataProvider {
  
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
