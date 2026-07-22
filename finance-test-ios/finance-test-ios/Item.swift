//
//  Item.swift
//  finance-test-ios
//
//  Created by Ewide Dev 5 on 22/07/26.
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
