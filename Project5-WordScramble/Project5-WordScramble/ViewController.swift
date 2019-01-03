//
//  ViewController.swift
//  Project5-WordScramble
//
//  Created by Kush, Ryan on 12/6/18.
//  Copyright © 2018 Kush, Ryan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var allWords: [String] = []
    var usedWords: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))

        loadDefaultWords()
        startGame()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()

        guard title?.lowercased() != lowerAnswer else {
            showErrorMessage(title: "Used same word", message: "You used the same word we're playing the game with!")
            return
        }

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                }
                else {
                    showErrorMessage(title: "Word not recognized", message: "You can't just make up words!")
                }
            }
            else {
                showErrorMessage(title: "Word already used", message: "Be more original!")
            }
        }
        else {
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from '\(title!.lowercased())'!")
        }

    }

    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        for letter in word {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            }
            else {
                return false
            }
        }
        return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    func isReal(word: String) -> Bool {
        guard word.utf16.count < 3 else {
            return false
        }
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }

    func loadDefaultWords() {
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
                return
            }
        }
        // We failed to do something, so just default to the "error list"
        allWords = ["silkworm"]
    }
}

