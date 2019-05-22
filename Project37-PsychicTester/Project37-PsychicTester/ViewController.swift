//
//  ViewController.swift
//  Project37-PsychicTester
//
//  Created by Kush, Ryan on 5/21/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var allCards = [CardViewController]()

    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var gradientView: GradientView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCards()
    }

    @objc func loadCards() {
        // Clean up any existing cards in the container.
        for card in allCards {
            card.view.removeFromSuperview()
            card.removeFromParent()
        }
        allCards.removeAll(keepingCapacity: true)

        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]

        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!

        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()

        for (index, position) in positions.enumerated() {

            // Create a new card and assign the delegate of the card to the parent VC
            let card = CardViewController()
            card.delegate = self

            // Add the card VC as a child of the current VC, add the cards view to the container view, and then call didMove to set card in container
            addChild(card)
            cardContainer.addSubview(card.view)
            card.didMove(toParent: self)

            // Position the card and set the image based on the loop
            card.view.center = position
            card.front.image = images[index]

            // If it is the "correct" image (star), let the card know.
            if card.front.image == star {
                card.isCorrect = true
            }

            // Append the card to our data source.
            allCards.append(card)

            // Reset the view to allow interaction
            view.isUserInteractionEnabled = true
        }
    }

    func cardTapped(_ tapped: CardViewController) {
        // Make sure we can interact with the card, and then turning off interaction with the view to allow only one card selection.
        guard view.isUserInteractionEnabled else { return }
        view.isUserInteractionEnabled = false

        for card in allCards {
            if card == tapped {
                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)
            }
            else {
                card.wasntTapped()
            }
        }
        perform(#selector(loadCards), with: nil, afterDelay: 2)
    }


}

