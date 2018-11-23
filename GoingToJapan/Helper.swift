//
//  FakeAPIManager.swift
//  GoingToJapan
//
//  Created by Andy Wong on 9/18/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    static let sharedInstance = Helper()
    func getCurrentTime() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
        dateFormatter.timeZone = NSTimeZone.system
        
        return dateFormatter.date(from: dateFormatter.string(from: Date())) ?? Date()
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy' 'hh:mm:ss a"
        dateFormatter.timeZone = NSTimeZone.system
        
        return dateFormatter.string(from: date)
    }
}
