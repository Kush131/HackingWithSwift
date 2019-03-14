//
//  MyGenresTableViewController.swift
//  Project33-WhatsTheWhistle
//
//  Created by Kush, Ryan on 3/14/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresTableViewController: UITableViewController {

    var myGenres: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if let savedGenres = defaults.object(forKey: "myGenres") as? [String] {
            myGenres = savedGenres
        }
        else {
            myGenres = [String]()
        }

        title = "Notify me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @objc func saveTapped() {
        let defaults = UserDefaults.standard
        defaults.set(myGenres, forKey: "myGenres")

        let database = CKContainer.default().publicCloudDatabase

        database.fetchAllSubscriptions { [unowned self] (subscriptions, error) in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (str, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                }
                for genre in self.myGenres {
                    let predicate = NSPredicate(format: "genre = %@", genre)
                    let subscription = CKQuerySubscription(recordType: "Whistles", predicate: predicate, options: .firesOnRecordCreation)
                    let notification = CKSubscription.NotificationInfo()
                    notification.alertBody = "There's a new whistle in the \(genre) genre"
                    notification.soundName = "default"
                    subscription.notificationInfo = notification

                    database.save(subscription, completionHandler: { (result, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })
                }
            }
            else {
                print(error!.localizedDescription)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SelectGenreViewController.genres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let genre = SelectGenreViewController.genres[indexPath.row]
        cell.textLabel?.text = genre

        if myGenres.contains(genre) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let selectedGenre = SelectGenreViewController.genres[indexPath.row]
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            }
            else {
                cell.accessoryType = .none
                if let index = myGenres.firstIndex(of: selectedGenre) {
                    myGenres.remove(at: index)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
