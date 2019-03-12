//
//  Whistle.swift
//  Project33-WhatsTheWhistle
//
//  Created by Kush, Ryan on 3/7/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import CloudKit

class Whistle: NSObject {
    var recordID: CKRecord.ID!
    var genre: String?
    var comments: String?
    var audio: URL!
}
