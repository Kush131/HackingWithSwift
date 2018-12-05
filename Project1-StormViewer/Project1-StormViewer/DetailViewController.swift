//
//  DetailViewController.swift
//  Project3-StormViewerSocial
//
//  Created by Kush, Ryan on 11/25/18.
//  Copyright © 2018 Kush, Ryan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var picture: UIImageView!
    var pictureName: String!

    override var prefersHomeIndicatorAutoHidden: Bool {
        return navigationController?.hidesBarsOnTap ?? false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        self.title = pictureName
        picture.image = UIImage.init(named: pictureName)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
