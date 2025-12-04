//
//  RequestsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RequestsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableViewController: UITableView!
    
    var incomingRequests: [User] = []
    var outgoingRequests: [User] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableViewController.delegate = self
        tableViewController.dataSource = self
        
        //        fetchRequests { users in
        //            self.incomingRequests = users
        //            self.tableViewController.reloadData()
        //            print("R")
        //            print(users.count)
        //        }
        fetchRequests { incoming, outgoing in
            self.incomingRequests = incoming
            self.outgoingRequests = outgoing
            self.tableViewController.reloadData()
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
    
//    func fetchRequests(completion: @escaping ([User], [User]) -> Void) {
//        guard let currentUID = Auth.auth().currentUser?.uid else {
//            print("❌ Not logged in")
//            completion([], [])
//            return
//        }
//        
//        db.collection("users").document(currentUID).getDocument { snapshot, error in
//            if let error = error {
//                print("❌ Couldn’t fetch user: \(error.localizedDescription)")
//                completion([], [])
//                return
//            }
//            
//            guard let data = snapshot?.data() else {
//                completion([], [])
//                return
//            }
//            
//            let incomingMap = data["incomingRequests"] as? [String: String] ?? [:]
//            let outgoingMap = data["outgoingRequests"] as? [String: String] ?? [:]
//            
//            let incomingUsers = incomingMap.map { (uid, username) in
//                User(id: uid, username: username, email: "")
//            }
//            
//            let outgoingUsers = outgoingMap.map { (uid, username) in
//                User(id: uid, username: username, email: "")
//            }
//            
//            completion(incomingUsers, outgoingUsers)
//        }
//    }
    func fetchRequests(completion: @escaping ([User], [User]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("❌ Not logged in")
            completion([], [])
            return
        }
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Couldn’t fetch user: \(error.localizedDescription)")
                completion([], [])
                return
            }
            
            guard let data = snapshot?.data() else {
                completion([], [])
                return
            }
            
            let incomingMap = data["incomingRequests"] as? [String: String] ?? [:]
            let outgoingMap = data["outgoingRequests"] as? [String: String] ?? [:]
            
            let dispatchGroup = DispatchGroup()
            var incomingUsers: [User] = []
            var outgoingUsers: [User] = []
            
            for (uid, username) in incomingMap {
                dispatchGroup.enter()
                self.db.collection("users").document(uid).getDocument { docSnapshot, error in
                    defer { dispatchGroup.leave() }
                    let profileURL = docSnapshot?.data()?["profilePictureURL"] as? String ?? ""
                    incomingUsers.append(User(id: uid, username: username, email: "", profilePictureURL: profileURL))
                }
            }
            
            for (uid, username) in outgoingMap {
                dispatchGroup.enter()
                self.db.collection("users").document(uid).getDocument { docSnapshot, error in
                    defer { dispatchGroup.leave() }
                    let profileURL = docSnapshot?.data()?["profilePictureURL"] as? String ?? ""
                    outgoingUsers.append(User(id: uid, username: username, email: "", profilePictureURL: profileURL))
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(incomingUsers, outgoingUsers)
            }
        }
    }

    
    
    func fetchHangoutCount(for user: User, completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        let plansRef = db.collection("users").document(user.id).collection("plans")
        
        plansRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch plans for \(user.username): \(error.localizedDescription)")
                completion(0)
                return
            }
            
            let count = snapshot?.documents.count ?? 0
            completion(count)
        }
    }
    
    func acceptFriendRequest(from user: User) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let currentUID = currentUser.uid
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let currentUsername = data["username"] as? String else {
                print("❌ Failed to load current user info")
                return
            }
            
            let currentUserRef = db.collection("users").document(currentUID)
            let senderUserRef = db.collection("users").document(user.id)
            
            let batch = db.batch()
            
            // 1. Remove from current user's incoming requests and add to friends
            batch.updateData([
                "incomingRequests.\(user.id)": FieldValue.delete(),
                "friends.\(user.id)": user.username
            ], forDocument: currentUserRef)
            
            // 2. Remove from sender's outgoing requests and add to friends
            batch.updateData([
                "outgoingRequests.\(currentUID)": FieldValue.delete(),
                "friends.\(currentUID)": currentUsername
            ], forDocument: senderUserRef)
            
            batch.commit { error in
                if let error = error {
                    print("❌ Failed to accept friend request: \(error.localizedDescription)")
                } else {
                    print("✅ Friend request from \(user.username) accepted")
                    self.reloadRequests()
                }
            }
        }
    }
    
    
    func denyFriendRequest(from user: User) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let currentRef = db.collection("users").document(currentUID)
        let senderRef = db.collection("users").document(user.id)
        
        let batch = db.batch()
        batch.updateData([
            "incomingRequests.\(user.id)": FieldValue.delete()
        ], forDocument: currentRef)
        
        batch.updateData([
            "outgoingRequests.\(currentUID)": FieldValue.delete()
        ], forDocument: senderRef)
        
        batch.commit { error in
            if let error = error {
                print("❌ Failed to deny: \(error)")
            } else {
                print("✅ Denied request from \(user.username)")
                self.reloadRequests()
            }
        }
    }
    
    func withdrawFriendRequest(to user: User) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let currentRef = db.collection("users").document(currentUID)
        let targetRef = db.collection("users").document(user.id)
        
        let batch = db.batch()
        batch.updateData([
            "outgoingRequests.\(user.id)": FieldValue.delete()
        ], forDocument: currentRef)
        
        batch.updateData([
            "incomingRequests.\(currentUID)": FieldValue.delete()
        ], forDocument: targetRef)
        
        batch.commit { error in
            if let error = error {
                print("❌ Failed to withdraw: \(error)")
            } else {
                print("✅ Withdrawn request to \(user.username)")
                self.reloadRequests()
            }
        }
    }
    
    func reloadRequests() {
        fetchRequests { incoming, outgoing in
            self.incomingRequests = incoming
            self.outgoingRequests = outgoing
            self.tableViewController.reloadData()
        }
    }
    
    
}

extension RequestsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? incomingRequests.count : outgoingRequests.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "INCOMING REQUESTS" : "SENT REQUESTS"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell", for: indexPath) as? RequestsCell else {
            return UITableViewCell()
        }
        
        let user = (indexPath.section == 0) ? incomingRequests[indexPath.row] : outgoingRequests[indexPath.row]
        
        cell.usernameLabel.text = user.username
        AvatarManager.loadAvatar(from: user.profilePictureURL, into: cell.profilePicImageView)
        
        fetchHangoutCount(for: user) { count in
            DispatchQueue.main.async {
                cell.bioLabel.text = count == 0 ? "New to Enehid" : "\(count) hangouts logged"
            }
        }
        
        if indexPath.section == 0 {
            // Incoming → Show Accept/Deny
            cell.withdrawButton.isHidden = true
            cell.addFriendButton.setTitle("Accept", for: .normal)
            cell.denyFriendButton.setTitle("Deny", for: .normal)
            cell.addFriendButton.isHidden = false
            cell.denyFriendButton.isHidden = false
            
            cell.onAddTapped = {
                self.acceptFriendRequest(from: user)
            }
            
            cell.onDenyTapped = {
                self.denyFriendRequest(from: user)
            }
            
        } else {
            // Outgoing → Show only Withdraw
            cell.denyFriendButton.isHidden = true
            cell.addFriendButton.isHidden = true
            
            cell.onWithdrawTapped = {
                self.withdrawFriendRequest(to: user)
            }
        }
        
        return cell
    }
}
