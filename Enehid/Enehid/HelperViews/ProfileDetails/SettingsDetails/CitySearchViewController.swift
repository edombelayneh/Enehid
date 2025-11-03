//
//  CitySearchViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/2/25.
//

import UIKit
//import CoreLocation
import MapKit

import FirebaseFirestore
import FirebaseAuth

protocol CitySearchDelegate: AnyObject {
    func didSelectCity(_ city: String)
}


class CitySearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, MKLocalSearchCompleterDelegate, UITableViewDataSource {
    
    weak var delegate: CitySearchDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults: [MKLocalSearchCompletion] = []
    
    var matchingCities: [CLPlacemark] = []
    let geocoder = CLGeocoder()
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "City Search"
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchCompleter.queryFragment = searchText
        }

        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            searchResults = completer.results
            tableView.reloadData()
        }

        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            print("❌ Search completer failed: \(error.localizedDescription)")
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchResults.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let completion = searchResults[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "CityCell")
            cell.textLabel?.text = completion.title
            cell.detailTextLabel?.text = completion.subtitle
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let completion = searchResults[indexPath.row]
            searchForLocation(completion)
        }
        
        func searchForLocation(_ completion: MKLocalSearchCompletion) {
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            
            search.start { response, error in
                guard let placemark = response?.mapItems.first?.placemark else {
                    print("❌ Couldn't resolve selected city")
                    return
                }

                let city = placemark.locality ?? placemark.name ?? "Unknown"
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                let fullName = [city, state, country].filter { !$0.isEmpty }.joined(separator: ", ")

                // Save or notify delegate
                self.saveSelectedCity(cityName: fullName, coordinate: placemark.coordinate)
            }
        }
        
        func saveSelectedCity(cityName: String, coordinate: CLLocationCoordinate2D) {
            let db = Firestore.firestore()
            let uid = Auth.auth().currentUser?.uid ?? ""
            
            let updateData: [String: Any] = [
                "preferredCity": cityName,
                "coordinates": [
                    "lat": coordinate.latitude,
                    "lon": coordinate.longitude
                ]
            ]
            
            db.collection("users").document(uid).setData([
                "settings": updateData
            ], merge: true) { error in
                if let error = error {
                    print("❌ Failed to save city: \(error.localizedDescription)")
                } else {
                    print("✅ Saved city: \(cityName)")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    
}

