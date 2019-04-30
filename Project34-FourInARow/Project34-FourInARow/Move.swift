//
//  Move.swift
//  Project34-FourInARow
//
//  Created by Kush, Ryan on 4/29/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var column: Int

    init(column: Int) {
        self.column = column
    }
}
