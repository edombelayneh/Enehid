//
//  ViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    var friends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchFriends {user in
            DispatchQueue.main.async {
                self.friends = user
                self.tableView.reloadData()
            }
            
            // ✅ Load avatar image
            //            if let urlString = user.profilePictureURL, let url = URL(string: urlString) {
            //                URLSession.shared.dataTask(with: url) { data, _, error in
            //                    if let data = data, error == nil {
            //                        DispatchQueue.main.async {
            //                            self.profilePicImageView.image = UIImage(data: data)
            //                            self.profilePicImageView.contentMode = .scaleAspectFill
            //                            self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.width / 2
            //                            self.profilePicImageView.layer.masksToBounds = true
            //                        }
            //                    }
            //                }.resume()
            //            }
        }
    }
    
    func fetchFriends(completion: @escaping ([User]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion([])
            return
        }
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = snapshot?.data(),
                  let friendDict = data["friends"] as? [String: String] else {
                print("❌ No friends found")
                completion([])
                return
            }
            
            var fetchedUsers: [User] = []
            let group = DispatchGroup()
            
            for (friendUID, username) in friendDict {
                group.enter()
                
                self.db.collection("users").document(friendUID).getDocument { friendSnapshot, error in
                    defer { group.leave() }
                    
                    guard let friendData = friendSnapshot?.data(), error == nil else {
                        print("⚠️ Failed to fetch friend \(username)")
                        return
                    }
                    
                    let user = User(
                        id: friendUID,
                        username: username,
                        email: friendData["email"] as? String ?? "",
                        profilePictureURL: friendData["profilePictureURL"] as? String,
                        friends: [:]
                    )
                    fetchedUsers.append(user)
                }
            }
            
            group.notify(queue: .main) {
                print("✅ Fetched \(fetchedUsers.count) friends")
                completion(fetchedUsers)
            }
        }
    }
}

extension FriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friend = friends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
        cell.usernameLabel.text = friend.username
        
        AvatarManager.loadAvatar(from: friend.profilePictureURL, into: cell.profilePicture, cropToFace: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        let chatVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        chatVC.recipientUser = friend
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}

