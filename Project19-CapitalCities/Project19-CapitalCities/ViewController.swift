//
//  ViewController.swift
//  Project19-CapitalCities
//
//  Created by Kush, Ryan on 1/27/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(displayMapOptions))

        // Create annotations
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the city of light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")

        mapView.addAnnotations([london, oslo, paris, rome, washington])


        // Do any additional setup after loading the view, typically from a nib.
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // We only want to create a view if we're dealing with our custom annotation.
        if annotation is Capital {
            let capital = annotation as! Capital
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Capital") as? MKPinAnnotationView else {
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Capital")
                annotationView.canShowCallout = true

                let btn = UIButton(type: .detailDisclosure)
                btn.tag = 1
                let fav = UIButton(type: .contactAdd)
                fav.tag = 2
                annotationView.rightCalloutAccessoryView = btn
                annotationView.leftCalloutAccessoryView = fav
                annotationView.annotation = annotation

                annotationView.pinTintColor = capital.favorite ? UIColor.blue : UIColor.red

                return annotationView
            }
            annotationView.pinTintColor = capital.favorite ? UIColor.blue : UIColor.red
            return annotationView
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let capital = view.annotation as! Capital
        if control.tag == 1 {
            let placeName = capital.title
            let placeInfo = capital.info

            let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        else {
            capital.favorite = !capital.favorite
            self.mapView.removeAnnotation(view.annotation!)
            self.mapView.addAnnotation(capital)
        }
    }

    @objc func displayMapOptions() {
        let ac = UIAlertController(title: "Map Options", message: nil, preferredStyle: .actionSheet)
        let standard = UIAlertAction(title: "Standard", style: .default) { [unowned self] _ in
            self.mapView.mapType = .standard
        }
        let hybrid = UIAlertAction(title: "Hybrid", style: .default) { [unowned self] _ in
            self.mapView.mapType = .hybrid
        }
        let satellite = UIAlertAction(title: "Satellite", style: .default) { [unowned self] _ in
            self.mapView.mapType = .satellite
        }
        ac.addAction(standard)
        ac.addAction(hybrid)
        ac.addAction(satellite)
        present(ac, animated: true)
    }

}

