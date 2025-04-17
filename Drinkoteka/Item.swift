//
//  Item.swift
//  Drinkoteka
//
//  Created by Jacek Skrobisz on 2025.04.17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
