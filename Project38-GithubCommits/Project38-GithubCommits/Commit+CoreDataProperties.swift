//
//  Commit+CoreDataProperties.swift
//  Project38-GithubCommits
//
//  Created by Kush, Ryan on 5/28/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date
    @NSManaged public var message: String
    @NSManaged public var sha: String
    @NSManaged public var url: String
    @NSManaged public var author: Author

}
