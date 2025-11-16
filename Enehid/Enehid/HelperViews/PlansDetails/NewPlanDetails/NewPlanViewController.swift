//
//  NewPlanViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/29/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewPlanViewController: UIViewController, UICollectionViewDelegate {
    
    
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var inviteFriendsCollectionView: UICollectionView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var activityTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    var selectedFriends: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityTextField.applyEnehidTFStyle()
        locationTextField.applyEnehidTFStyle()
        // Do any additional setup after loading the view.
        inviteFriendsCollectionView.dataSource = self
        inviteFriendsCollectionView.delegate = self
        
        inviteFriendsCollectionView.register(
            UINib(nibName: "InviteFriendCell", bundle: nil),
            forCellWithReuseIdentifier: "InviteFriendCell"
        )
        
    }
    
    
    @IBAction func onTappedSchedule(_ sender: UIButton) {
        guard let activity = activityTextField.text, !activity.isEmpty else {
            print("Missing activity name")
            return
        }
        
        guard let location = locationTextField.text, !location.isEmpty else {
            print("Missing location")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let formattedDate = formatter.string(from: dateTimePicker.date)
        
        let groupName = "DefaultGroup" // Replace with real group picker later
        
        let participants: [String: String] = selectedFriends.reduce(into: [:]) { dict, user in
            dict[user.id] = user.username
        }
        
        createNewPlan(
            activityName: activity,
            location: location,
            date: formattedDate,
            group: groupName,
            participants: participants
        )
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func createNewPlan(activityName: String,
                       location: String,
                       date: String,
                       group: String,
                       participants: [String: String]) {
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let planRef = db.collection("plans").document()
        let planId = planRef.documentID
        
        let planData: [String: Any] = [
            "activityName": activityName,
            "location": location,
            "date": date,
            "group": group,
            "createdBy": currentUID,
            "participants": participants,           // [uid: username]
            "acceptedByIDs": [],                    // empty at first
            "declinedByIDs": []                     // empty at first
        ]
        
        // Write to /plans/{planId}
        planRef.setData(planData) { error in
            if let error = error {
                print("❌ Failed to create plan: \(error)")
                return
            }
            print("✅ Plan created successfully!")
            
            // Link plan to all users involved
            for (uid, _) in participants {
                db.collection("users")
                    .document(uid)
                    .collection("plans")
                    .document(planId)
                    .setData(["planId": planId])
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
}

extension NewPlanViewController: UICollectionViewDataSource {
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
        } else {
            let user = selectedFriends[indexPath.item]
            cell.nameLabel.text = user.username
            
            if let urlStr = user.profilePictureURL,
               let url = URL(string: urlStr),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                cell.imageView.image = image
            } else {
                cell.imageView.image = UIImage(named: "default_avatar")
            }
        }
        
        return cell
    }
}


