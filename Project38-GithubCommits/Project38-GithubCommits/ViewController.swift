//
//  ViewController.swift
//  Project38-GithubCommits
//
//  Created by Kush, Ryan on 5/23/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var container: NSPersistentContainer!

    var commitPredicate: NSPredicate?
    var fetchedResultsController: NSFetchedResultsController<Commit>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))

        // Finds the location of the database on disk, or creates one if not present
        container = NSPersistentContainer(name: "Project38")

        // Loads database from disk into memory
        container.loadPersistentStores { (storeDescription, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error: \(String(describing: error))")
            }
        }

        performSelector(inBackground: #selector(fetchCommits), with: nil)
        loadSavedData()
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            }
            catch {
                print("An error has occured while trying to save. Error: \(error)")
            }
        }
    }

    @objc func fetchCommits() {

        let newestCommitDate = getNewestCommitDate()

        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {
            let jsonCommits = JSON(parseJSON: data)
            let jsonCommitArray = jsonCommits.arrayValue
            print("Received \(jsonCommitArray.count) new commits")

            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                self.saveContext()
                self.loadSavedData()
            }
        }
    }

    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()

        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1

        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }

    // Take a commit and JSON and configure the commit with data from the JSON
    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["url"].stringValue

        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()

        var commitAuthor: Author!

        // Create a request to try to find the author in our database
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["commiter"]["name"].stringValue)

        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                // We found an author, so return it
                commitAuthor = authors[0]
            }
        }

        if commitAuthor == nil {
            // We didn't find an author, so create a new one with all of the relevant info
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        commit.author = commitAuthor
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        let commit = fetchedResultsController.object(at: indexPath)

        cell.textLabel?.text = commit.message
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.detailItem = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
            saveContext()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }

    func loadSavedData() {
        if fetchedResultsController == nil {
            // Create the NSFetchRequest
            let request = Commit.createFetchRequest()
            // Create the sort descriptor which will tell us how to order the data we get back
            let sort = NSSortDescriptor(key: "author.name", ascending: false)
            // Add the sort descriptor to the request to apply the ordering.
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20

            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            fetchedResultsController.delegate = self
        }
        fetchedResultsController.fetchRequest.predicate = commitPredicate

        do {
            // Try to see if we can fetch data from the Github URL.
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch {
            print("Fetch failed")
        }
    }

    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)

        // Predicate filters out messages that don't contain the text 'fix'
        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        }))

        // Predicate filters out messages that begin with 'Merge pull request'
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        }))

        // Predicate filters out messages older that 12 hours.
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default, handler: { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
        }))

        // Predicate filtering out every commit that doesn't have the author name of 'Joe Groff'
        ac.addAction(UIAlertAction(title: "Show only Durian commits", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        }))

        // No predicate, don't do any filtering
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData()
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
}

