//
//  ViewController.swift
//  Project34-FourInARow
//
//  Created by Kush, Ryan on 3/15/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    @IBOutlet var columnButtons: [UIButton]!

    var placedChips = [[UIView]]()
    var board: Board!

    var strategist: GKMinmaxStrategist!

    override func viewDidLoad() {
        super.viewDidLoad()

        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 7
        strategist.randomSource = GKARC4RandomSource()

        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        resetBoard()
    }

    func resetBoard() {
        board = Board()
        strategist.gameModel = board
        updateUI()

        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }

    func columnForAIMove() -> Int? {
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }
        return nil
    }

    func makeAIMove(in column: Int) {
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)

            // Player can make a move now, so enable buttons again and get rid of loading spinner.
            columnButtons.forEach { $0.isEnabled = true }
            navigationItem.leftBarButtonItem = nil

            continueGame()
        }
    }

    func startAIMove() {
        // Disable buttons so the player cannot make a move for the AI
        columnButtons.forEach { $0.isEnabled = false }
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)

        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let column = self.columnForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.makeAIMove(in: column)
            })
        }
    }

    func addChip(inColumn column: Int, row: Int, color: UIColor) {
        // Retrieve the button, calculate the size based off of that button, and then provide a
        // CGRect based off of that size for the frame of the new chip.
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        /*
         Create a new chip (UIView) and set various properties to make it look like a chip.
         */
        if(placedChips[column].count < row + 1) {
            let newChip = UIView()
            newChip.frame = rect
            // No user interaction so the press is passed back to the background button.
            newChip.isUserInteractionEnabled = false
            newChip.backgroundColor = color
            newChip.layer.cornerRadius = size / 2
            newChip.center = positionForChip(inColumn: column, row: row)
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)
            view.addSubview(newChip)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                newChip.transform = CGAffineTransform.identity
            })
            placedChips[column].append(newChip)
        }
    }

    func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        let columnButton = columnButtons[column]
        let size = min(columnButton.frame.width, columnButton.frame.height / 6)
        let midX = columnButton.frame.midX
        var yOffset = columnButton.frame.maxY - size / 2
        yOffset -= size * CGFloat(row)
        return CGPoint(x: midX, y: yOffset)
    }

    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            continueGame()
        }
    }

    func updateUI() {
        title = "\(board.currentPlayer.name)'s turn"
        if board.currentPlayer.chip == .black { startAIMove() }
    }

    func continueGame() {
        var gameOverTitle: String? = nil

        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        }
        else if board.isFull() {
            gameOverTitle = "Draw!"
        }

        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { _ in
                self.resetBoard()
            }
            alert.addAction(alertAction)
            present(alert, animated: true)

            return
        }
        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }
    
}

