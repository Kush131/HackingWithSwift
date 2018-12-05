//
//  ViewController.swift
//  Project2-GuessTheFlag
//
//  Created by Kush, Ryan on 11/28/18.
//  Copyright © 2018 Kush, Ryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var flagOne: UIButton!
    @IBOutlet weak var flagTwo: UIButton!
    @IBOutlet weak var flagThree: UIButton!

    var countries: [String] = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    var score = 0
    var correctAnswer = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        flagOne.layer.borderWidth = 1
        flagOne.layer.borderColor = UIColor.lightGray.cgColor

        flagTwo.layer.borderWidth = 1
        flagTwo.layer.borderColor = UIColor.lightGray.cgColor

        flagThree.layer.borderWidth = 1
        flagThree.layer.borderColor = UIColor.lightGray.cgColor

        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        flagOne.setImage(UIImage(named: countries[0]), for: .normal)
        flagTwo.setImage(UIImage(named: countries[1]), for: .normal)
        flagThree.setImage(UIImage(named: countries[2]), for: .normal)
        correctAnswer = Int.random(in: 0...2)
        navigationItem.title = countries[correctAnswer].uppercased()
    }

    @IBAction func flagTapped(_ sender: UIButton) {
        var title = ""
        if sender.tag == correctAnswer {
            score += 1
            print("Correct!")
            title = "Correct!"
        }
        else {
            score -= 1
            print("Wrong!")
            title = "Wrong!"
        }
        let ac = UIAlertController(title: title, message: "Score is now \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }

}

