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

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    
    var username = ""
    var preferredCity = ""
    var radiusMiles = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        searchBar.isHidden = true
        loadUserSettings()
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

    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -40 {
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 1): // Change Password
            presentChangePasswordAlert()
//        case (1, 0): // Preferred City
//            presentCitySearch()
        case (1, 1): // Radius
            presentRadiusPicker()
        case (3, 0): // Sign Out
            handleSignOut()
        default:
            break
        }
    }
    
    

    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
                
//                self.username = data["username"] as? String ?? "Unknown"
                self.preferredCity = data["preferredCity"] as? String ?? "Not Set"
                self.radiusMiles = data["preferredRadiusMiles"] as? Int ?? 10
                
                DispatchQueue.main.async {
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
    
    
    func presentRadiusPicker() {
        let alert = UIAlertController(title: "Select Radius", message: nil, preferredStyle: .actionSheet)
        [5, 10, 25, 50].forEach { value in
            alert.addAction(UIAlertAction(title: "\(value) miles", style: .default) { _ in
                self.saveRadiusPreference(miles: value)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }

    func saveRadiusPreference(miles: Int) {
        db.collection("users").document(currentUID).setData([
            "settings.preferredRadiusMiles": miles
        ], merge: true)
        self.radiusMiles = miles
        self.tableView.reloadData()
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
    
}
