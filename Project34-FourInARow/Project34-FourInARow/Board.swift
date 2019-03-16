//
//  Board.swift
//  Project34-FourInARow
//
//  Created by Kush, Ryan on 3/15/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit

class Board: NSObject {

    enum ChipColor: Int {
        case none = 0
        case red
        case black
    }

    static var height = 6
    static var width = 7

    var slots = [ChipColor]()

    override init() {
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }
        super.init()
    }

    func chip(inColumn column: Int, row: Int) -> ChipColor {
        return slots[row + column * Board.height]
    }

    func set(chip: ChipColor, in column: Int, row: Int) {
        slots[row + column * Board.height] = chip
    }

    func nextEmptySlot(in column: Int) -> Int? {
        for row in 0 ..< Board.height {
            if chip(inColumn: 0, row: row) == .none {
                return row
            }
        }
        return nil
    }

    func canMove(in column: Int) -> Bool {
        return nextEmptySlot(in: column) != nil
    }

    func add(chip: ChipColor, in column: Int) {
        if let row = nextEmptySlot(in: column) {
            set(chip: chip, in: column, row: row)
        }
    }
}
