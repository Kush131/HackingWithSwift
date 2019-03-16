//
//  ViewController.swift
//  Project34-FourInARow
//
//  Created by Kush, Ryan on 3/15/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var columnButtons: [UIButton]!

    var placedChips = [[UIView]]()
    var board: Board!

    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        resetBoard()
    }

    func resetBoard() {
        board = Board()

        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }

    @IBAction func makeMove(_ sender: UIButton) {
    }
    
}

