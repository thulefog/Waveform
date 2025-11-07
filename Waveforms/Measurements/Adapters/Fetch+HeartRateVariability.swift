//
//  FetchHeartRateVariabilityForDateRange.swift
//  Measurements
//
//  Created by John Matthew Weston on 2/9/18.
//  Copyright © 2018. All rights reserved.
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
import UIKit

class FetchHeartRateVariabilityForDateRange {
    
    func execute() {
        
        print( "\(#function): ENTER")
        DispatchQueue.main.async (execute: {
            let date = Date()
            let calendar = Calendar(identifier: .gregorian)
            let startDate = calendar.startOfDay(for: date)
            
            let timeInterval = TimeInterval( 86400 )
            let endDate = Date( timeInterval: timeInterval, since: startDate as Date  )
            
            HealthDataAdapter.instance.fetchHRVSamples( startDate: startDate,
                                                            endDate: endDate,
                                                            callback: self.callback )
        })
    }

    func callback( key: String, sdnnSet: [Double]? ) -> Bool {
        
        print( "\(#function): \(key)", key )
        
        DispatchQueue.main.async {
            if( sdnnSet != nil )
            {
                let trace = "heartRateVariabilitySDNN: N: \(String(describing: sdnnSet?.count)) | SAMPLES: \(sdnnSet as AnyObject)"
                
                let alertController = UIAlertController(title: "fetchHRVSamples", message: trace, preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alertController.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                
                // show alert
                let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                alertWindow.rootViewController = UIViewController()
                alertWindow.windowLevel = UIWindow.Level.alert + 1;
                alertWindow.makeKeyAndVisible()
                alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
 
        return true
    }
}



