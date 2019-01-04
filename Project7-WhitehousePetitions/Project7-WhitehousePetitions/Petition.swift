//
//  Petition.swift
//  Project7-WhitehousePetitions
//
//  Created by Kush, Ryan on 1/4/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
