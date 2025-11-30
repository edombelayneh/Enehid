//
//  ViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendsViewController: RefreshableViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    var friends: [User] = []
    var groupPreviews: [GroupChatPreview] = []
    
    var groupChatListener: ListenerRegistration?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchFriends {user in
            DispatchQueue.main.async {
                self.friends = user
                self.emptyStateView.isHidden = !self.friends.isEmpty
                self.tableView.reloadData()
            }
        }
        
        observeGroupChats()
        
    }
    
    override func handleRefresh() {
        print("🔁 FriendsViewController refreshing...")
        friends = []
        groupPreviews = []
        tableView.reloadData()
        
        let group = DispatchGroup()
        
        group.enter()
        fetchFriends { users in
            DispatchQueue.main.async {
                self.friends = users
                self.tableView.reloadData()
            }
            group.leave()
        }
        
        group.enter()
        observeGroupChats() // no completion block, so we just assume it's fast
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // simulate slight delay
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.endRefreshing()
        }
    }
    
    
    func observeGroupChats() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in")
            return
        }
        
        let userPlansRef = db.collection("users").document(uid).collection("plans")
        
        // Remove old listener if it exists
        groupChatListener?.remove()
        
        groupChatListener = userPlansRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Failed to listen for user plans: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var updatedPreviews: [GroupChatPreview] = []
            let group = DispatchGroup()
            
            for doc in documents {
                let planId = doc.documentID
                let activityName = doc.data()["activityName"] as? String ?? "Group Chat"
                
                group.enter()
                
                self.db.collection("groupChats").document(planId).getDocument { chatSnapshot, error in
                    defer { group.leave() }
                    
                    guard let chatData = chatSnapshot?.data(),
                          let participants = chatData["participants"] as? [String: Any],
                          let participantInfo = participants[uid] as? [String: Any],
                          let status = participantInfo["status"] as? String else {
                        return
                    }
                    
                    var lastMessage = (chatData["lastMessage"] as? [String: Any])?["text"] as? String ?? ""
                    if lastMessage == "" {
                        lastMessage = "Start a conversation with your friends!"
                    }
                    
                    let preview = GroupChatPreview(
                        planId: planId,
                        lastMessageText: lastMessage,
                        timestamp: Timestamp(), // optionally replace with real timestamp
                        groupName: activityName,
                        role: status
                    )
                    
                    updatedPreviews.append(preview)
                }
            }
            
            group.notify(queue: .main) {
                self.groupPreviews = updatedPreviews
                self.tableView.reloadData()
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
    
    func generateGroupAvatar(from urls: [String], size: CGFloat) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        let avatarSize = size * 0.6
        let overlapOffset = avatarSize * 0.4
        
        for (index, urlString) in urls.prefix(3).enumerated() {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: CGFloat(index) * overlapOffset, y: 0, width: avatarSize, height: avatarSize)
            imageView.layer.cornerRadius = avatarSize / 2
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            // Assuming you already have a working AvatarManager
            AvatarManager.loadAvatar(from: urlString, into: imageView, cropToFace: true)
            
            container.addSubview(imageView)
        }
        
        return container
    }
    
    func fetchParticipantAvatars(for planId: String, completion: @escaping ([String]) -> Void) {
        db.collection("groupChats").document(planId).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let participants = data["participants"] as? [String: Any] else {
                completion([])
                return
            }
            
            var urls: [String] = []
            for (_, value) in participants {
                if let info = value as? [String: Any],
                   let url = info["profilePictureURL"] as? String {
                    urls.append(url)
                }
            }
            completion(urls)
        }
    }
    
    deinit {
        groupChatListener?.remove()
    }
    
    
    
}

extension FriendsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0: Friends, Section 1: Group Chats
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? groupPreviews.count : friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let friend = friends[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
            cell.usernameLabel.text = friend.username
            //            cell.messagePreviewLabel.text = friend.
            AvatarManager.loadAvatar(from: friend.profilePictureURL, into: cell.profilePicture, cropToFace: true)
            return cell
        } else {
            let chat = groupPreviews[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsCell
            
            // Title
            cell.usernameLabel.text = chat.groupName
            
            // Subtitle (optional)
            cell.messagePreviewLabel.text = chat.role == "invited" ? "Tap to accept invite" : chat.lastMessageText
            
            // Gray out text if not accepted
            cell.usernameLabel?.textColor = chat.role == "accepted" ? .label : .gray
            
            // 👇 Dynamically generate group avatar
            let avatarSize = cell.profilePicture.frame.width
            fetchParticipantAvatars(for: chat.planId) { urls in
                DispatchQueue.main.async {
                    let avatarView = self.generateGroupAvatar(from: urls, size: avatarSize)
                    avatarView.frame = cell.profilePicture.bounds
                    cell.profilePicture.subviews.forEach { $0.removeFromSuperview() } // clear previous
                    cell.profilePicture.addSubview(avatarView)
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let friend = friends[indexPath.row]
            let chatVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
            chatVC.recipientUser = friend
            navigationController?.pushViewController(chatVC, animated: true)
        } else {
            let preview = groupPreviews[indexPath.row]
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
        return section == 0 ? "GROUP CHATS" : "FRIENDS"
    }
}



