//
//  Person.swift
//  Project10-NamesToFaces
//
//  Created by Kush, Ryan on 1/9/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit

class Person: NSObject {

    var name: String
    var image: String

    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

}
