//
//  Item.swift
//  Threads
//
//  Created by Kush Agrawal on 5/23/25.
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
