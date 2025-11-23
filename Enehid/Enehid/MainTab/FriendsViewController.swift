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
    var groupPreviews: [GroupChatPreview] = []

    
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
            
        
        }
        fetchGroupChats { previews in
            self.groupPreviews = previews
            print("previews: \(previews)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
    
//    func fetchGroupChats(completion: @escaping ([GroupChatPreview]) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("❌ User not logged in")
//            completion([])
//            return
//        }
//
//        let userPlansRef = db.collection("users").document(uid).collection("plans")
//        userPlansRef.getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else {
//                print("❌ Failed to fetch user plans: \(error?.localizedDescription ?? "Unknown error")")
//                completion([])
//                return
//            }
//
//            var groupPreviews: [GroupChatPreview] = []
//            let group = DispatchGroup()
//            
//            for doc in documents {
//                let planId = doc.documentID
//                group.enter()
//                
//                self.db.collection("groupChats")
//                    .document(planId)
//                    .getDocument { chatSnapshot, error in
//                        guard let chatData = chatSnapshot?.data(),
//                              let participants = chatData["participants"] as? [String: Any],
//                              let currentUser = Auth.auth().currentUser?.uid,
//                              let participantInfo = participants[currentUser] as? [String: Any],
//                              let status = participantInfo["status"] as? String else {
//                            print("⚠️ Could not find participant status for planId: \(planId)")
//                            group.leave()
//                            return
//                        }
//
//                        self.db.collection("groupChats")
//                            .document(planId)
//                            .collection("messages")
//                            .order(by: "timestamp", descending: true)
//                            .limit(to: 1)
//                            .getDocuments { messageSnapshot, error in
//                                defer { group.leave() }
//
//                                guard let messageDoc = messageSnapshot?.documents.first,
//                                      let data = messageDoc.data() as? [String: Any],
//                                      let text = data["text"] as? String,
//                                      let timestamp = data["timestamp"] as? Timestamp else {
//                                    print("⚠️ No last message found for group \(planId)")
//                                    return
//                                }
//
//                                let preview = GroupChatPreview(
//                                    planId: planId,
//                                    lastMessageText: text,
//                                    timestamp: timestamp,
//                                    groupName: "Group Chat",
//                                    role: status
//                                )
//
//                                groupPreviews.append(preview)
//                            }
//                    }
//            }
//
//            group.notify(queue: .main) {
//                completion(groupPreviews.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
//            }
//        }
//    }
    
    func fetchGroupChats(completion: @escaping ([GroupChatPreview]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in")
            completion([])
            return
        }

        let userPlansRef = db.collection("users").document(uid).collection("plans")
        userPlansRef.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Failed to fetch user plans: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            var groupPreviews: [GroupChatPreview] = []
            let group = DispatchGroup()

            for doc in documents {
                let planId = doc.documentID
                group.enter()

                self.db.collection("groupChats")
                    .document(planId)
                    .getDocument { chatSnapshot, error in
                        defer { group.leave() }

                        guard let chatData = chatSnapshot?.data(),
                              let participants = chatData["participants"] as? [String: Any],
                              let participantInfo = participants[uid] as? [String: Any],
                              let status = participantInfo["status"] as? String else {
                            print("⚠️ Could not find participant status for planId: \(planId)")
                            return
                        }

                        let preview = GroupChatPreview(
                            planId: planId,
                            lastMessageText: "", // not used anymore
                            timestamp: Timestamp(), // default
                            groupName: "Group Chat", // placeholder, customize later
                            role: status
                        )

                        groupPreviews.append(preview)
                    }
            }

            group.notify(queue: .main) {
                completion(groupPreviews)
            }
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
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return friends.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let friend = friends[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
//        cell.usernameLabel.text = friend.username
//        
//        AvatarManager.loadAvatar(from: friend.profilePictureURL, into: cell.profilePicture, cropToFace: true)
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let friend = friends[indexPath.row]
//        let chatVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
//        chatVC.recipientUser = friend
//        navigationController?.pushViewController(chatVC, animated: true)
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0: Friends, Section 1: Group Chats
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? friends.count : groupPreviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let friend = friends[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
            cell.usernameLabel.text = friend.username
            AvatarManager.loadAvatar(from: friend.profilePictureURL, into: cell.profilePicture, cropToFace: true)
            return cell
        } else {
//            let chat = groupPreviews[indexPath.row]
//            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatCell", for: indexPath)
//            cell.textLabel?.text = chat.groupName
//            cell.detailTextLabel?.text = chat.lastMessageText
//            
//            // Gray out if not accepted
//            if chat.role == "invited" {
//                cell.textLabel?.textColor = .gray
//                cell.detailTextLabel?.text = "Tap to Accept Invitation"
//            } else {
//                cell.textLabel?.textColor = .label
//            }
//            return cell
            let chat = groupPreviews[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath)

            // Title
            cell.textLabel?.text = chat.groupName

            // Subtitle (optional)
            cell.detailTextLabel?.text = chat.role == "invited" ? "Tap to accept invite" : "Tap to open chat"

            // Gray out text if not accepted
            cell.textLabel?.textColor = chat.role == "accepted" ? .label : .gray
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let friend = friends[indexPath.row]
            let chatVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
            chatVC.recipientUser = friend
            navigationController?.pushViewController(chatVC, animated: true)
        } else {
            let preview = groupPreviews[indexPath.row]

//            if preview.role == "accepted" {
//                let chatVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
//                chatVC.currentPlanId = preview.planId
//                navigationController?.pushViewController(chatVC, animated: true)
//            } else {
//                // Show alert or custom action
//                let alert = UIAlertController(title: "Pending Invitation", message: "You have been invited to this group chat. Accept the invite to participate.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                present(alert, animated: true)
//            }
            if preview.role == "accepted" {
                let chatVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                chatVC.currentPlanId = preview.planId
                navigationController?.pushViewController(chatVC, animated: true)
            } else {
                let alert = UIAlertController(title: "Pending Invitation", message: "You have been invited to this group chat. Accept the invite to participate.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }


        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Friends" : "Group Chats"
    }

    
//    func didSelectGroupChat(at index: Int) {
//        let preview = groupPreviews[index]
//        
//        let chatVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
//        chatVC.currentPlanId = preview.planId
//        navigationController?.pushViewController(chatVC, animated: true)
//    }

    
}



