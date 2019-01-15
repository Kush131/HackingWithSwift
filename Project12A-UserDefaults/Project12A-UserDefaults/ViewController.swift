//
//  ViewController.swift
//  Project12A-UserDefaults
//
//  Created by Kush, Ryan on 1/15/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedPeople = UserDefaults.standard.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                people = decodedPeople ?? [Person]()
            }
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }

    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        let personRef = people[indexPath.item]
        let personPath = getDocumentsDirectory().appendingPathComponent(personRef.image)

        cell.name.text = personRef.name
        cell.imageView.image =  UIImage(contentsOfFile: personPath.path)

        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] _ in
            let newName = ac.textFields![0]
            person.name = newName.text!
            self.save()

            self.collectionView.reloadData()
        })
        present(ac, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Since the dictionary is defined as a UIImagePickerController.InfoKey, we can use dot syntax
        // as a shortcut and ask for the original image from the dictionary. The value returned is an
        // Any, so we need to try to cast to a UIImage.
        guard let image = info[.originalImage] as? UIImage else {
            return
        }

        // Generate a unique ID as a string
        let imageName = UUID().uuidString

        // Grab the URL for the documents direcory and append the image name to the end
        // so we can save to that directory.
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

        // Try create jpegData from the image with a compression quality of .8 and then try
        // to write it to the path we created earlier. We need to do this because UIImage
        // cannot be saved directly to a path, but a Data object can.
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        // Create a new person object based off of the info we got from above, store it in our
        // people property, and then reload the collectionView
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        self.save()

        collectionView.reloadData()
        dismiss(animated: true)
    }

    func getDocumentsDirectory() -> URL {
        // Get the dictionary of document directory URLs and return the first one (since that
        // is the one we need to use). userDomainMask means we want the path relative to the
        // users home directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}


