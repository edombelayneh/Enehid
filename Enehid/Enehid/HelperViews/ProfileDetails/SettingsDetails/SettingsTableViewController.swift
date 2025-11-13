//
//  SettingsTableViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/2/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class SettingsTableViewController: UITableViewController, CitySearchDelegate {
    //    @objc func dismissKeyboard() {
    //        view.endEditing(true)
    //    }
    
    @IBOutlet weak var signOutCellCV: UIView!
    @IBOutlet weak var radiusCellCV: UIView!
    @IBOutlet weak var preferredCityCellCV: UIView!
    @IBOutlet weak var changePaswordCellCV: UIView!
    @IBOutlet weak var usernameCellCV: UIView!
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    var username = ""
    var preferredCity = ""
    var radiusMiles = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserSettings()
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //        view.addGestureRecognizer(tapGesture)
        
        style(container: usernameCellCV)
        style(container: changePaswordCellCV)
        style(container: preferredCityCellCV)
        style(container: radiusCellCV)
        style(container: signOutCellCV)
        
        tableView.separatorStyle = .none
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToCitySearch" {
            // No data to pass right now
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserSettings()
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("🔥 Tapped cell at section: \(indexPath.section), row: \(indexPath.row)")
        
        switch (indexPath.section, indexPath.row) {
        case (0, 1): // Change Password
            presentChangePasswordAlert()
        case (1, 0): // Preferred City
            presentCitySearch()
        case (1, 1): // Radius
            presentRadiusPicker()
        case (2, 0): // Sign Out
            handleSignOut()
        default:
            break
        }
    }
    
    // MARK: - Navigation
    func loadUserSettings() {
        let userRef = db.collection("users").document(currentUID)
        let settingsRef = db.collection("users")
            .document(currentUID)
            .collection("settings")
            .document("preferences")
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("⚠️ No user found.")
                return
            }
            
            self.username = data["username"] as? String ?? "Unknown"
            
            settingsRef.getDocument { snapshot, error in
                if let error = error {
                    print("❌ Error fetching settings: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("⚠️ No settings found.")
                    return
                }
                
                self.preferredCity = data["preferredCity"] as? String ?? "Not Set"
                self.radiusMiles = data["preferredRadiusMiles"] as? Int ?? 10
                
                DispatchQueue.main.async {
                    self.usernameLabel.text = "@\(self.username)"
                    self.cityLabel.text = self.preferredCity
                    self.radiusLabel.text = "\(self.radiusMiles) mi"
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    
    func presentChangePasswordAlert() {
        let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "New Password"; $0.isSecureTextEntry = true }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { _ in
            guard let newPass = alert.textFields?.first?.text, !newPass.isEmpty else { return }
            Auth.auth().currentUser?.updatePassword(to: newPass) { error in
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                } else {
                    print("✅ Password updated")
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    
    func updateCityPreference(city: String) {
        let geo = CLGeocoder()
        geo.geocodeAddressString(city) { placemarks, error in
            guard let location = placemarks?.first?.location else { return }
            let coords = location.coordinate
            
            let settingsUpdate: [String: Any] = [
                "preferredCity": city,
                "coordinates": ["lat": coords.latitude, "lon": coords.longitude]
            ]
            
            self.db.collection("users").document(self.currentUID).setData([
                "settings": settingsUpdate
            ], merge: true)
        }
    }
    
    func didSelectCity(_ city: String) {
        print("🏙️ City chosen: \(city)")
        preferredCity = city
        cityLabel.text = city
        tableView.reloadData()
    }
    
    func presentRadiusPicker() {
        let alert = UIAlertController(title: "Select Radius", message: nil, preferredStyle: .actionSheet)
        [25, 50, 100, 250, 500].forEach { value in
            alert.addAction(UIAlertAction(title: "\(value) miles", style: .default) { _ in
                self.saveRadiusPreference(miles: value)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func saveRadiusPreference(miles: Int) {
        let settingsRef = db.collection("users")
            .document(currentUID)
            .collection("settings")
            .document("preferences")
        
        settingsRef.setData([
            "preferredRadiusMiles": miles
        ], merge: true)
        
        self.radiusMiles = miles
        self.radiusLabel.text = "\(miles) mi"
        self.tableView.reloadData()
    }
    
    
    func presentCitySearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let cityVC = storyboard.instantiateViewController(withIdentifier: "CitySearchViewController") as? CitySearchViewController {
            cityVC.delegate = self
            navigationController?.pushViewController(cityVC, animated: true)
        }
    }
    
    
    func handleSignOut() {
        do {
            try Auth.auth().signOut()
            
            // Navigate to Login or Onboarding
            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        } catch let signOutError as NSError{
            print("Error signing out: %@", signOutError)
            let alert = UIAlertController(title: "Logout Failed", message: signOutError.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func style(container: UIView) {
        
        if let superview = container.superview {
            container.frame = container.frame.insetBy(dx: 16, dy: 0)
        }
        
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 6
        container.backgroundColor = .white
    }
    
    
}
