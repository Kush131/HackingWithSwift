//
//  ViewController.swift
//  Project18-Debugging
//
//  Created by Kush, Ryan on 1/25/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(1, 2, 3, 4, 5, separator: "-")
        print("Some message", terminator: "")
        assert(1==1, "Never Fail!")
        // assert(1==2, "Always fails!")
        for i in 1...100 {
            print("Got number \(i)")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }


}

