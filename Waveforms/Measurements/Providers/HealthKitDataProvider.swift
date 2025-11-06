//
//  HealthKitDataProvider
//  Measurements
//
//  Created by John Matthew Weston in January 2015, updated to Swift 2.x in December 2015 and added types and queries
//
//  Copyright © 2015-2017 John Matthew Weston. All rights reserved.
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

import HealthKit
import UIKit


public class HealthKitDataProvider {
    
    //Singletons are  at times an anti pattern, but one one HKHealthStore needed per app - so taking this approach for now.
    //https://developer.apple.com/reference/healthkit
    public class var instance: HealthKitDataProvider {
        struct Singleton {
            static let instance = HealthKitDataProvider()
        }
        
        return Singleton.instance
    }
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()

    public func requestHealthKitAuthorization() {
        
        let _: Set<HKSampleType> = self.dataTypesToWrite()
        let readDataTypes: Set<HKObjectType> = self.dataTypesToRead()

        healthStore?.requestAuthorization(toShare: nil, read: readDataTypes ) {
            success, error in
            
            if (error != nil) {
                print("request authorization for HealthStore failed", error!)
            } else {
                if (success) {
                    print("request authorization for HealthStore successful")
                } else {
                    print("request authorization for HealthStore failed")
                }
            }
        }
        
    }

    private func dataTypesToWrite() -> Set<HKSampleType> {
        let dietaryCalorieEnergyType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!
        let activeEnergyBurnType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        let heightType:  HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let weightType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        
        let writeDataTypes: Set<HKSampleType> = [dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType]
        
        return writeDataTypes
    }
    
    private func dataTypesToRead() -> Set<HKObjectType> {
        let birthdayType: HKCharacteristicType = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!
        let biologicalSexType: HKCharacteristicType = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!
        let heightType:  HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let weightType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

        let dietaryCalorieEnergyType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!
        let activeEnergyBurnType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        let distanceWalkRun: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let stepCount: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let heartRate: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let heartRateVariability: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!

        let readDataTypes: Set<HKObjectType> = [ birthdayType, biologicalSexType, heightType, weightType, dietaryCalorieEnergyType, activeEnergyBurnType, distanceWalkRun, stepCount, heartRate, heartRateVariability, HKObjectType.electrocardiogramType() ]
        
        return readDataTypes
    }

}


