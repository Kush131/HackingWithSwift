//
//  Player.swift
//  Project34-FourInARow
//
//  Created by Kush, Ryan on 4/23/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import GameplayKit

class Player: NSObject, GKGameModelPlayer {
    
    var chip: Board.ChipColor
    var color: UIColor
    var name: String
    var playerId: Int

    static var allPlayers = [Player(chip: .red), Player(chip: .black)]

    var opponent: Player {
        if chip == .red {
            return Player.allPlayers[1]
        }
        else {
            return Player.allPlayers[0]
        }
    }

    init(chip: Board.ChipColor) {
        self.chip = chip
        self.playerId = chip.rawValue

        if chip == .red {
            color = .red
            name = "Red"
        }
        else {
            color = .black
            name = "Black"
        }
        super.init()
    }
}
