//
//  PlaidCore.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 12/17/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Foundation

struct PlaidDate {
    let year: Int
    let month: Int
    let day: Int
    fileprivate var plaidDate: String {
        if year < 1000 || year > 9999 {
            fatalError("Incorrect year amount")
        }
        if month <= 0 || month > 12 {
            fatalError("Incorrect month amount")
        }
        if day <= 0 || day > 32 {
            fatalError("Incorrect day amount")
        }
        let yearString = "\(year)"
        var monthString = "\(month)"
        var dayString = "\(day)"
        if month < 10 {
            monthString = "0" + monthString
        }
        if day < 10 {
            dayString = "0" + dayString
        }
        return "\(yearString)-\(month)-\(day)"
    }
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
}

struct PlaidTransaction {
    
}
