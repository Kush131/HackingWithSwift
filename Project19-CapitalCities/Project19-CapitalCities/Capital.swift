//
//  Capital.swift
//  Project19-CapitalCities
//
//  Created by Kush, Ryan on 1/27/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var favorite: Bool = false

    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info

    }

}
