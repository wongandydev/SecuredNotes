//
//  DayPassObject.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/27/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class Notes{
    var date: String
    var password: String
    var note: String
    var title: String
    
    init(date: String, password: String = "", note: String, title: String) {
        self.date = date
        self.password = password
        self.note = note
        self.title = title
    }
}

extension Notes: Equatable {
    static func == (lhs: Notes, rhs: Notes) -> Bool {
        return lhs.date == rhs.date && lhs.note == rhs.note && lhs.password == rhs.password && lhs.title == rhs.password
    }
}
