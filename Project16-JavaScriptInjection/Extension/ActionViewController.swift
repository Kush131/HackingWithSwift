//
//  ActionViewController.swift
//  Extension
//
//  Created by Kush, Ryan on 1/21/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!

    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                    let itemDictionary = dict as! NSDictionary
                    let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    self.pageTitle = javaScriptValues["title"] as! String
                    self.pageURL = javaScriptValues["URL"] as! String

                    DispatchQueue.main.async {
                        self.title = self.pageTitle

                        // load user defaults for website if it exists
                        if let scriptForWebsite = UserDefaults.standard.object(forKey:self.pageURL) as? Data {
                            let jsonDecoder = JSONDecoder()
                            do {
                                let stringDict = try jsonDecoder.decode([String].self, from: scriptForWebsite)
                                if let code = stringDict.first {
                                    self.script.text = code
                                }
                            } catch {
                                print("No script for existing address")
                            }
                        }
                    }

                }
            }
        }
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode([self.script.text]) {
            UserDefaults.standard.set(savedData, forKey: self.pageURL)
        }
        else {
            print("Failed to save script")
        }
    }

    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!

        let keyboardScreenEndFrome = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrome, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = UIEdgeInsets.zero
        }
        else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        script.scrollIndicatorInsets = script.contentInset
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)

        item.attachments = [customJavaScript]

        self.extensionContext!.completeRequest(returningItems: [item])
        self.save()
    }

}
