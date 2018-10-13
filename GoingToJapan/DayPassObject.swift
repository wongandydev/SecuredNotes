//
//  DayPassObject.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/27/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class DayPassObject{
    var date: String
    var password: String
    var letter: String
    
    init(date: String, password: String = "", letter: String) {
        self.date = date
        self.password = password
        self.letter = letter
    }
}
