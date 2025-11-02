//
//  CitySearchViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/2/25.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

protocol CitySearchDelegate: AnyObject {
    func didSelectCity(_ city: String)
}


class CitySearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate {
    
    weak var delegate: CitySearchDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            matchingCities.removeAll()
            tableView.reloadData()
            return
        }
        
        geocoder.geocodeAddressString(searchText) { placemarks, error in
            if let error = error {
                print("❌ Geocoding error: \(error.localizedDescription)")
                return
            }
            
            self.matchingCities = placemarks?.filter { $0.locality != nil } ?? []
            self.tableView.reloadData()
        }
    }
    
    func saveSelectedCity(city: CLPlacemark) {
        guard
            let cityName = city.locality,
            let location = city.location
        else {
            print("❌ Missing city name or location")
            return
        }
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        let updateData: [String: Any] = [
            "preferredCity": cityName,
            "coordinates": [
                "lat": lat,
                "lon": lon
            ]
        ]
        
        db.collection("users")
            .document(currentUID)
            .collection("settings")
            .document("preferences")
            .setData(updateData, merge: true) { error in
                if let error = error {
                    print("❌ Failed to save city: \(error.localizedDescription)")
                } else {
                    print("✅ City \(cityName) saved")
                    
                    // ✅ Notify delegate
                    self.delegate?.didSelectCity(cityName)
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
    }
    
    
//    // Call this after user selects a city
//    func citySelected(_ city: String) {
//        delegate?.didSelectCity(city)
//        navigationController?.popViewController(animated: true)
//    }
    
    
}

extension CitySearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = matchingCities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "CityCell")
        cell.textLabel?.text = city.locality ?? "Unknown City"
        cell.detailTextLabel?.text = city.administrativeArea ?? city.country ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = matchingCities[indexPath.row]
        saveSelectedCity(city: selectedCity)
    }
}


//extension Array where Element: Hashable {
//    func uniqued() -> [Element] {
//        Array(Set(self))
//    }
//}


