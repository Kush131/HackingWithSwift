//
//  ResultsTableViewController.swift
//  Project33-WhatsTheWhistle
//
//  Created by Kush, Ryan on 3/13/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class ResultsTableViewController: UITableViewController {

    var whistle: Whistle!
    var suggestions = [String]()
    var whistlePlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Genre: \(whistle.genre!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadTapped))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf)
        let pred = NSPredicate(format: "owningWhistle == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Suggestions", predicate: pred)
        query.sortDescriptors = [sort]

        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] (results, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                if let results = results {
                    self.parseResults(records: results)
                }
            }
        }
    }

    func parseResults(records: [CKRecord]) {
        var newSuggestions = [String]()

        for record in records {
            newSuggestions.append(record["text"] as! String)
        }

        DispatchQueue.main.async { [unowned self] in
            self.suggestions = newSuggestions
            self.tableView.reloadData()
        }
    }

    func add(suggestion: String) {

        // Create a new whistleRecord that will be a suggestion that refers to a given whistle.'s
        let whistleRecord = CKRecord(recordType: "Suggestions")

        // Create a reference that refers to our whistle ID with the action "deleteSelf".
        // This will ensure the referenced object (the suggestion) is deleted if the whistle
        // is deleted.
        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf)

        // Create "text" key that refers to the suggestion we want to add to the whistle.
        whistleRecord["text"] = suggestion as CKRecordValue

        // Create a key that refers to our "Owning" whistle, which is the ref we created above.
        whistleRecord["owningWhistle"] = reference as CKRecordValue

        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] (record, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.suggestions.append(suggestion)
                    self.tableView.reloadData()
                }
                else {
                    let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }

    @objc func downloadTapped() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.tintColor = UIColor.black
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)

        CKContainer.default().publicCloudDatabase.fetch(withRecordID: whistle.recordID) { [unowned self] (record, error) in
            if let error = error {
                print("Error! \(error.localizedDescription))")
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(self.downloadTapped))
                }
            }
            else {
                if let record = record {
                    if let asset = record["audio"] as? CKAsset {
                        self.whistle.audio = asset.fileURL
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen", style: .plain, target: self, action: #selector(self.listenTapped))
                        }
                    }
                }
            }
        }
    }

    @objc func listenTapped() {
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: whistle.audio)
            whistlePlayer.play()
        }
        catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your whistle; Please try again later", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Suggested songs"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return suggestions.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0

        if indexPath.section == 0 {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title1)

            if whistle.comments?.count == 0 {
                cell.textLabel?.text = "Comments: None"
            }
            else {
                cell.textLabel?.text = whistle.comments
            }
        }
        else {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            if indexPath.row == suggestions.count {
                cell.textLabel?.text = "Add suggestion"
                cell.selectionStyle = .gray
            }
            else {
                cell.textLabel?.text = suggestions[indexPath.row]
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }

        tableView.deselectRow(at: indexPath, animated: true)
        let ac = UIAlertController(title: "Suggest a song", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] action in
            if let textField = ac.textFields?[0] {
                if textField.text!.count > 0 {
                    self.add(suggestion: textField.text!)
                }
            }
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

}
