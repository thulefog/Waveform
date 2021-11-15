//
//  Repository.swift
//  Waveforms
//
//  Created by John Matthew Weston on 11/12/21.
//

import Foundation

protocol IRepository {
    associatedtype T
    
    func get(id: Int, completionHandler: (T?, Error?) -> Void)
    func list(completionHandler: ([T]?, Error?) -> Void)
    func add(_ item: T, completionHandler: (Error?) -> Void)
    func delete(_ item: T, completionHandler: (Error?) -> Void)
    func edit(_ item: T, completionHandler: (Error?) -> Void)
}
typealias ECGSampleType = [Double:Double]

struct ECGRepository : IRepository {
    typealias T = ECGSampleType

    func get(id: Int, completionHandler: (ECGSampleType?, Error?) -> Void) {
        /*
                    if let error = error {
                        completionHandler(nil, error)
                        return
                    }

                    guard let ... else {
                        completionHandler(nil, RepositoryError.notFound)
                        return
                    }

                    completionHandler(domainUser, nil)
        */
    }
    
    func list(completionHandler: ([ECGSampleType]?, Error?) -> Void) {
        
    }
    
    func add(_ item: ECGSampleType, completionHandler: (Error?) -> Void) {
        
    }
    
    func delete(_ item: ECGSampleType, completionHandler: (Error?) -> Void) {
        
    }
    
    func edit(_ item: ECGSampleType, completionHandler: (Error?) -> Void) {
        
    }
    
}
