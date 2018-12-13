//
//  DayPassObject.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/27/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

class Notes{
    var uid: String
    var dateCreated: String
    var dateModified: String
    var password: String
    var note: String
    var title: String
    
    init(uid: String, dateCreated: String, dateModified: String, password: String = "", note: String, title: String) {
        self.uid = uid
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.password = password
        self.note = note
        self.title = title
    }
}

extension Notes: Equatable {
    static func == (lhs: Notes, rhs: Notes) -> Bool {
        return lhs.uid == rhs.uid && lhs.dateCreated == rhs.dateCreated && lhs.dateModified == rhs.dateModified && lhs.note == rhs.note && lhs.password == rhs.password && lhs.title == rhs.password
    }
}
