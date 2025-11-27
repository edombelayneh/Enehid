//
//  ViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    var coordinate: CLLocationCoordinate2D?
    var locationName: String?


    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let coordinate = coordinate else { return }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = locationName ?? "Selected Location"
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
}
