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
    
//    func readJSON() -> [DayPassObject]{
//        var daysArr: [DayPassObject] = []
//        
//        if let filePath = Bundle.main.path(forResource: "fakeData", ofType: "json") {
//            do {
//                let json = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
//                let jsonResults = try JSONSerialization.jsonObject(with: json, options: .mutableLeaves)
//                if let jsonResults = jsonResults as? [AnyObject] {
//                    for result in jsonResults {
//                        if let date = result["date"] as? String,
//                            let password = result["password"] as? String,
//                            let letter = result["note"] as? String{
//                            daysArr.append(DayPassObject(date: date, password: password, letter: letter))
//                        }
//                    }
//                }
//            } catch {
//                
//            }
//        }
//        
//        return daysArr
//    }
    
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
