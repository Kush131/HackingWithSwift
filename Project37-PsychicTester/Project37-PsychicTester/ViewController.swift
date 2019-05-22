//
//  ViewController.swift
//  Project37-PsychicTester
//
//  Created by Kush, Ryan on 5/21/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import AVFoundation
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    var allCards = [CardViewController]()

    var music: AVAudioPlayer!

    var lastMessage: CFAbsoluteTime = 0

    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var gradientView: GradientView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }

        view.backgroundColor = UIColor.red

        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
            self.view.backgroundColor = UIColor.blue
        })
        createParticles()
        loadCards()
        playMusic()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let instructions = "Please ensure your Apple Watch is configured correctly. On your iPhone, launch Apple's 'Watch' configuration app then choose General > Wake Screen. On that screen, please disable Wake Screen On Wrist Raise, then select Wake For 70 Seconds. On your Apple Watch, please swipe up on your watch face and enable Silent Mode. You're done!"
        let ac = UIAlertController(title: "Adjust your settings", message: instructions, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "I'm Ready", style: .default))
        present(ac, animated: true)
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

    func createParticles() {
        // Create layer for emitting distractions
        let particleEmitter = CAEmitterLayer()

        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = 2 // Create two objects every second
        cell.lifetime = 5.0 // Each object lives 5 seconds
        cell.velocity = 100 // How fast the object flies
        cell.velocityRange = 50 // Variation on object velocity
        cell.emissionLongitude = .pi
        cell.spinRange = 5 // Amount of variation on spins of object
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]
        gradientView.layer.addSublayer(particleEmitter)
    }

    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                music = audioPlayer
                music.numberOfLoops = -1
                music.play()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer) // Return the point of the UIView

        for card in allCards {
            if card.view.frame.contains(location) { // If our view contains the location of the press
                if view.traitCollection.forceTouchCapability == .available { // We have 3D Touch enabled
                    if touch.force == touch.maximumPossibleForce {
                        card.front.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    }
                }
                if card.isCorrect {
                    sendWatchMessage()
                }
            }
        }
    }

    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()

        if lastMessage + 0.5 > currentTime { return }

        if WCSession.default.isReachable {
            let message = ["Message" : "Hello"]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
        lastMessage = CFAbsoluteTimeGetCurrent()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

}

