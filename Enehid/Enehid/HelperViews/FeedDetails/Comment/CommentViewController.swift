//
//  CommentViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/26/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentInputField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    var memoryId: String!
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        commentInputField.delegate = self
        loadCurrentUserAvatar()
        loadComments()
        addShadowToAvatar(profilePictureImageView)
    }
    
    private func addShadowToAvatar(_ imageView: UIImageView) {
        imageView.layer.shadowColor = UIColor.textButton.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.layer.shadowRadius = 6
        imageView.layer.masksToBounds = false
    }
    
    
    func loadComments() {
        let db = Firestore.firestore()
        db.collection("memories")
            .document(memoryId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading comments: \(error)")
                    return
                }
                
                self.comments = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    return Comment(
                        username: data["username"] as? String ?? "Unknown",
                        text: data["text"] as? String ?? "",
                        timestamp: data["timestamp"] as? Timestamp ?? Timestamp(),
                        userId: data["userId"] as? String ?? "",
                        profilePictureURL: data["profilePictureURL"] as? String
                    )
                } ?? []
                
                self.tableView.reloadData()
            }
    }
    
    
    func loadCurrentUserAvatar() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    print("❌ Error fetching user profile: \(error)")
                    return
                }
                
                let avatarURL = snapshot?.data()?["profilePictureURL"] as? String
                AvatarManager.loadAvatar(from: avatarURL, into: self.profilePictureImageView)
            }
    }
    
    
    @IBAction func sendTapped(_ sender: UIButton) {
        guard let text = commentInputField.text, !text.isEmpty,
              let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let commentRef = db.collection("memories")
            .document(memoryId)
            .collection("comments")
            .document()
        
        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .getDocument { snapshot, error in
                
                let avatarURL = snapshot?.data()?["profilePictureURL"] as? String ?? ""
                let username = snapshot?.data()?["username"] as? String ?? "Anonymous"
                
                let data: [String: Any] = [
                    "text": text,
                    "username": username,
                    "userId": user.uid,
                    "timestamp": Timestamp(),
                    "profilePictureURL": avatarURL
                ]
                
                commentRef.setData(data) { error in
                    if let error = error {
                        print("Failed to save comment: \(error)")
                    } else {
                        self.commentInputField.text = ""
                        self.loadComments()
                    }
                }
            }
        
        //        // ✅ Fetch user info first (so we can store profilePictureURL)
        //        db.collection("users").document(user.uid).getDocument { snapshot, error in
        //            let avatarURL = snapshot?.data()?["profilePictureURL"] as? String ?? ""
        //
        //            let data: [String: Any] = [
        //                "text": text,
        //                "username": user.displayName ?? "Anonymous",
        //                "userId": user.uid,
        //                "timestamp": Timestamp(),
        //                "profilePictureURL": avatarURL // ✅ saved into comment!
        //            ]
        //
        //            commentRef.setData(data) { error in
        //                if let error = error {
        //                    print("Failed to save comment: \(error)")
        //                } else {
        //                    self.commentInputField.text = ""
        //                    self.loadComments()
        //                }
        //            }
        //        }
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        
        let comment = comments[indexPath.row]
        cell.configure(with: comment)
        
        // 💅 Round styling
//        cell.backgroundColor = UIColor.creamBackground
//        cell.layer.cornerRadius = 20
//        cell.layer.masksToBounds = true
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOpacity = 0.5
//        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
//        cell.layer.shadowRadius = 6
//        cell.selectionStyle = .none
        
        return cell
    }
    
}

