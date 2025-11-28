//
//  NewPlanViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/29/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MapKit


class NewPlanViewController: UIViewController, UICollectionViewDelegate, UITableViewDelegate, MKLocalSearchCompleterDelegate {
    
    @IBOutlet weak var locationResultsTableView: UITableView!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var inviteFriendsCollectionView: UICollectionView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var activityTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    var selectedFriends: [User] = []
    var prefillFromPlan: Plans?
    
    
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults: [MKLocalSearchCompletion] = []
    
    var selectedLocation: (name: String, lat: Double, lon: Double)?
    
    @objc func locationTextChanged(_ textField: UITextField) {
        guard let query = textField.text, !query.isEmpty else {
            searchResults = []
            locationResultsTableView.isHidden = false
            locationResultsTableView.reloadData()
            return
        }
        
        searchCompleter.queryFragment = query
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let plan = prefillFromPlan {
            activityTextField.text = plan.activityName
            locationTextField.text = plan.location
            selectedLocation = (plan.location, plan.lat, plan.lon)
        }
        
        
        activityTextField.applyEnehidTFStyle()
        locationTextField.applyEnehidTFStyle()
        searchCompleter.delegate = self
        locationTextField.addTarget(self, action: #selector(locationTextChanged), for: .editingChanged)
        // Do any additional setup after loading the view.
        inviteFriendsCollectionView.dataSource = self
        inviteFriendsCollectionView.delegate = self
        locationResultsTableView.dataSource = self
        locationResultsTableView.delegate = self
        locationResultsTableView.isHidden = false
        
        styleScheduleButton()
        applyTextFieldShadow(activityTextField)
        applyTextFieldShadow(locationTextField)
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // <-- This is the fix!
        view.addGestureRecognizer(tapGesture)
        
        inviteFriendsCollectionView.register(
            UINib(nibName: "InviteFriendCell", bundle: nil),
            forCellWithReuseIdentifier: "InviteFriendCell"
        )
        
    }
    
    
    @IBAction func onTappedSchedule(_ sender: UIButton) {
        guard let activity = activityTextField.text, !activity.isEmpty,
              let locationData = selectedLocation else {
            print("⚠️ Missing activity or location")
            return
        }
        
        guard let location = locationTextField.text, !location.isEmpty else {
            print("Missing location")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let formattedDate = formatter.string(from: dateTimePicker.date)
        
        let participants: [String: String] = selectedFriends.reduce(into: [:]) { dict, user in
            dict[user.id] = user.username
        }
        
        
        
        createNewPlan(
            activityName: activity,
            location: locationData.name,
            date: formattedDate,
            participants: participants,
            lat: locationData.lat,
            lon: locationData.lon
        )
        
        // ✅ Go back to previous screen
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func styleScheduleButton() {
        scheduleButton.layer.cornerRadius = 12
        scheduleButton.clipsToBounds = true
        scheduleButton.layer.shadowColor = UIColor.black.cgColor
        scheduleButton.layer.shadowOpacity = 0.2
        scheduleButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        scheduleButton.layer.shadowRadius = 6
        scheduleButton.layer.masksToBounds = false
        
        //        dateTimePicker.preferredDatePickerStyle = .compact
        dateTimePicker.tintColor = .softPurple // Your theme color
        dateTimePicker.layer.cornerRadius = 10
        dateTimePicker.backgroundColor = .creamBackground
        dateTimePicker.layer.shadowColor = UIColor.textButton.cgColor
        dateTimePicker.layer.shadowOpacity = 0.5
        dateTimePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        dateTimePicker.layer.shadowRadius = 10
        
        locationResultsTableView.separatorStyle = .none
        
    }
    
    func applyTextFieldShadow(_ textField: UITextField) {
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.05
        textField.layer.shadowOffset = CGSize(width: 0, height: 1)
        textField.layer.shadowRadius = 4
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = false
    }
    
    
    func createNewPlan(activityName: String,
                       location: String,
                       date: String,
                       participants: [String: String],
                       lat: Double,
                       lon: Double) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUID = currentUser.uid
        let db = Firestore.firestore()
        let planRef = db.collection("plans").document()
        let planId = planRef.documentID
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching creator data: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let creatorUsername = data["username"] as? String else {
                print("❌ Failed to get username for current user")
                return
            }
            
            
            // ✅ Include creator in participants
            var fullParticipants = participants
            fullParticipants[currentUID] = creatorUsername
            
            
            
            let planData: [String: Any] = [
                "activityName": activityName,
                "location": location,
                "date": date,
                "createdBy": currentUID,
                "lat": lat,
                "lon": lon,
                "participants": fullParticipants,
                "acceptedByIDs": [currentUID], // creator has accepted by default
                "declinedByIDs": []
            ]
            
            print("Plan Data: \(planData)")
            
            // ✅ Create the plan document
            planRef.setData(planData) { error in
                if let error = error {
                    print("❌ Failed to create plan: \(error)")
                    return
                }
                print("✅ Plan created successfully!")
                
                // ✅ Write to /users/{uid}/plans/{planId} for all participants (including creator)
                for (uid, _) in fullParticipants {
                    let userPlanRef = db.collection("users")
                        .document(uid)
                        .collection("plans")
                        .document(planId)
                    
                    let status = (uid == currentUID) ? "accepted" : "pending"
                    
                    userPlanRef.setData([
                        "planId": planId,
                        "createdBy": currentUID,
                        "status": status,
                        "activityName": activityName,
                        "date": date,
                        "location": location,
                        "lastUpdated": Timestamp(date: Date())
                    ]) { error in
                        if let error = error {
                            print("⚠️ Failed to write user plan link for \(uid): \(error)")
                        }
                    }
                }
            }
            
            // ✅ Create group chat for this plan
            let groupChatRef = db.collection("groupChats").document(planId) // use same ID as plan
            var groupChatParticipants: [String: [String: Any]] = [:]
            
            for (uid, username) in fullParticipants {
                groupChatParticipants[uid] = [
                    "username": username,
                    "status": uid == currentUID ? "accepted" : "invited"
                ]
            }
            
            let groupChatData: [String: Any] = [
                "planId": planId,
                "createdAt": Timestamp(date: Date()),
                "participants": groupChatParticipants
            ]
            
            groupChatRef.setData(groupChatData) { error in
                if let error = error {
                    print("❌ Failed to create group chat: \(error)")
                } else {
                    print("✅ Group chat created!")
                }
            }
        }
    }
    
    func presentFriendPicker() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerVC = storyboard.instantiateViewController(withIdentifier: "FriendPickerViewController") as! FriendPickerViewController
        
        pickerVC.selectedFriends = Set(selectedFriends.map { $0.id })
        
        pickerVC.onSelectionComplete = { [weak self] selected in
            self?.selectedFriends = selected
            self?.inviteFriendsCollectionView.reloadData()
        }
        
        present(pickerVC, animated: true)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        locationResultsTableView.reloadData()
        locationResultsTableView.isHidden = searchResults.isEmpty
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Search failed: \(error)")
    }
    
    func getCurrentLocationAndSetField() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(),
           let currentLoc = locationManager.location {
            
            let lat = currentLoc.coordinate.latitude
            let lon = currentLoc.coordinate.longitude
            
            // Optionally reverse-geocode:
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(currentLoc) { placemarks, error in
                let name = placemarks?.first?.name ?? "Current Location"
                self.locationTextField.text = name
                self.selectedLocation = (name, lat, lon)
            }
        }
    }
    
}

extension NewPlanViewController: UICollectionViewDataSource, UITableViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFriends.count + 1 // +1 for the Add button
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedFriends.count {
            presentFriendPicker()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "InviteFriendsCell",
            for: indexPath
        ) as! InviteFriendsCell
        
        let isAddCell = indexPath.item == selectedFriends.count
        
        if isAddCell {
            cell.imageView.image = UIImage(systemName: "plus.circle.fill")
            cell.nameLabel.text = "Add"
            cell.imageView.tintColor = .softPurple
            cell.imageView.layer.cornerRadius = cell.imageView.frame.width / 2
            cell.imageView.clipsToBounds = true
            
        } else {
            let user = selectedFriends[indexPath.item]
            cell.nameLabel.text = user.username
            
            if let urlStr = user.profilePictureURL {
                AvatarManager.loadAvatar(from: urlStr, into: cell.imageView, cropToFace: true)
            } else {
                cell.imageView.image = UIImage(systemName: "person")
                cell.imageView.tintColor = .softPurple
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationResultCell")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "LocationResultCell")
        if indexPath.row == 0 {
            cell.textLabel?.text = "📍 My Current Location"
            cell.detailTextLabel?.text = nil
        } else {
            let result = searchResults[indexPath.row - 1]
            cell.textLabel?.text = result.title
            cell.detailTextLabel?.text = result.subtitle
            
            cell.textLabel?.text = result.title
            cell.detailTextLabel?.text = result.subtitle
        }
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = .creamBackground
        cell.layer.shadowColor = UIColor.textButton.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 3
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        if indexPath.row == 0 {
            getCurrentLocationAndSetField()
            return
        }
        
        search.start { response, error in
            guard let placemark = response?.mapItems.first?.placemark else { return }
            
            let name = placemark.name ?? ""
            let lat = placemark.coordinate.latitude
            let lon = placemark.coordinate.longitude
            
            self.locationTextField.text = name
            self.selectedLocation = (name, lat, lon)
            
            print("📍 Stored: \(name) at (\(lat), \(lon))")
                        self.locationResultsTableView.isHidden = false
        }
    }
    
}




