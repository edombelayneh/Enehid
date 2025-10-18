//
//  AddFriendViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

enum FriendshipStatus {
    case friends
    case incomingRequest
    case outgoingRequest
    case notConnected
}


class AddFriendViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate {

    @IBOutlet weak var searchtableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBar.delegate = self
        searchtableView.delegate = self
        searchtableView.dataSource = self
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
        // Live search as user types
        print("Searching for: \(searchText)")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Called when keyboard Search button is tapped
        searchBar.resignFirstResponder() // hide keyboard
        performSearch(with: searchBar.text ?? "")
        
    }

    func performSearch(with query: String){
        guard !query.isEmpty else {
            print("🔍 Empty search — skipping")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("username", isEqualTo: query)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error searching users: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    print("❌ No users found")
                    return
                }
                
                let results = docs.map { doc -> User in
                    let data = doc.data()
                    return User(
                        id: doc.documentID,
                        username: data["username"] as? String ?? "",
                        email: data["email"] as? String ?? ""
                    )
                }
                
                print("✅ Found users: \(results)")
                // Optionally reload a table view with these results
                self.searchResults = results
                self.searchtableView.reloadData()
            }
        
    }
    
    func getFriendshipStatus(with targetUser: User, completion: @escaping (FriendshipStatus) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(.notConnected)
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                completion(.notConnected)
                return
            }
            
            let friends = data["friends"] as? [String: String] ?? [:]
            let incoming = data["incomingRequests"] as? [String: String] ?? [:]
            let outgoing = data["outgoingRequests"] as? [String: String] ?? [:]
            
            let targetUID = targetUser.id
            
            if friends.keys.contains(targetUID) {
                completion(.friends)
            } else if incoming.keys.contains(targetUID) {
                completion(.incomingRequest)
            } else if outgoing.keys.contains(targetUID) {
                completion(.outgoingRequest)
            } else {
                completion(.notConnected)
            }
        }
    }

    
    func sendFriendRequest(to targetUser: User) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let currentUID = currentUser.uid
        var isFriend = false
        var isIncoming = false
        var isOutgoing = false
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let currentUsername = data["username"] as? String,
                  let currentFriendList = data["friends"] as? [String:String],
                  let incomingRequests = data["incomingRequests"] as? [String:String],
                  let outgoingRequests = data["outgoingRequests"] as? [String:String]
                else { return }
            
            
            let targetUID = targetUser.id
            let targetUsername = targetUser.username
            
            let currentUserRef = db.collection("users").document(currentUID)
            let targetUserRef = db.collection("users").document(targetUID)
            
            let batch = db.batch()
            
            // if the target user had already requested current user just print Accept button
            for incoming in incomingRequests.keys {
                print("incoming: \(incoming)")
                if (targetUID == incoming) {
                    isIncoming = true
                    print("Friend already wants to connect")
                }
            }
            
            // if the current user had already requested before just print pending on button
            for outgoing in outgoingRequests.keys {
                print("outgoing: \(outgoing)")
                if (targetUID == outgoing) {
                    isOutgoing = true
                    print("Friend already wants to connect")
                }
            }
            
            // if target user is friends with current user just print Friends on the button and disable it
            for currentFriend in currentFriendList.keys{
                print("\(targetUID) is \(targetUsername)")
                print("currentFriend is \(currentFriend)")
                if (targetUID == currentFriend) {
                    isFriend = true
                    print("Already Friends with target User")
                }
                
            }
            
            if (isFriend == false) || (isIncoming == false) || (isOutgoing == false) {
                // Update outgoingRequests of current user
                batch.updateData([
                    "outgoingRequests.\(targetUID)": targetUsername
                ], forDocument: currentUserRef)
                
                // Update incomingRequests of target user
                batch.updateData([
                    "incomingRequests.\(currentUID)": currentUsername
                ], forDocument: targetUserRef)
                
                batch.commit { error in
                    if let error = error {
                        print("❌ Failed to send friend request: \(error.localizedDescription)")
                    } else {
                        print("✅ Friend request sent to \(targetUsername)")
                    }
                }
            }
        }
    }
    
    func acceptFriendRequest(from senderUID: String, senderUsername: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let currentUID = currentUser.uid
        //        let currentUsername = currentUser.displayName ?? "Unknown"
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let currentUsername = data["username"] as? String
//                  let currentFriendList = data["friends"] as? [String:String],
//                  let incomingRequests = data["incomingRequests"] as? [String:String],
//                  let outgoingRequests = data["outgoingRequests"] as? [String:String]
            else { return }
            
            let currentUserRef = db.collection("users").document(currentUID)
            let senderUserRef = db.collection("users").document(senderUID)
            
            let batch = db.batch()
            
            // 1. Remove from incomingRequests
            batch.updateData([
                "incomingRequests.\(senderUID)": FieldValue.delete(),
                "friends.\(senderUID)": senderUsername
            ], forDocument: currentUserRef)
            
            // 2. Remove from sender’s outgoingRequests, add to friends
            batch.updateData([
                "outgoingRequests.\(currentUID)": FieldValue.delete(),
                "friends.\(currentUID)": currentUsername
            ], forDocument: senderUserRef)
            
            
            batch.commit { error in
                if let error = error {
                    print("❌ Failed to accept friend request: \(error.localizedDescription)")
                } else {
                    print("✅ Friend request from \(senderUsername) accepted")
                }
            }
        }
    }

}

extension AddFriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as? AddFriendCell else {
            return UITableViewCell()
        }
        
        let user = searchResults[indexPath.row]
        cell.usernameLabel.text = user.username

        getFriendshipStatus(with: user) { status in
            DispatchQueue.main.async {
                switch status {
                case .friends:
                    cell.addFriendButton.setTitle("Friends", for: .normal)
                    cell.addFriendButton.isEnabled = false

                case .incomingRequest:
                    cell.addFriendButton.setTitle("Accept", for: .normal)
                    cell.addFriendButton.isEnabled = true
                    cell.onAddTapped = {
                        self.acceptFriendRequest(from: user.id, senderUsername: user.username)
                        cell.addFriendButton.setTitle("Friends", for: .normal)
                        cell.addFriendButton.isEnabled = false
                        print("✅ Accepting request from \(user.username)")
                    }

                case .outgoingRequest:
                    cell.addFriendButton.setTitle("Sent", for: .normal)
                    cell.addFriendButton.isEnabled = false

                case .notConnected:
                    cell.addFriendButton.setTitle("Add", for: .normal)
                    cell.addFriendButton.isEnabled = true
                    cell.onAddTapped = {
                        self.sendFriendRequest(to: user)
                        cell.addFriendButton.setTitle("Sent", for: .normal)
                        cell.addFriendButton.isEnabled = false
                    }
                }
            }
        }

        return cell
    }
    
    
}
