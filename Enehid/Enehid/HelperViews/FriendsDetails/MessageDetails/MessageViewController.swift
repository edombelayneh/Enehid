//
//  MessageViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/29/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MessageViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var inputBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    var messages: [Message] = []
    
    var listener: ListenerRegistration?
    
    var currentPlanId: String?
    var recipientUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        
//        navigationItem.title = "GROUP NAME HERE"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.register(MessageBubbleCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension

        
        if let planId = currentPlanId {
            navigationItem.title = "Group Chat"
            startGroupChatListener(planId: planId)
        } else if let user = recipientUser {
            navigationItem.title = user.username
            ensurePrivateChatExists(with: user)
            startPrivateChatListener(with: user)
        }

    }
    
    @IBAction func onTapSendMessage(_ sender: UIButton) {
        sendMessage()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height

        inputBottomConstraint.constant = -keyboardHeight

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.scrollToBottom()
        }
    }

//    
//    @objc func keyboardWillShow(notification: Notification) {
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//        let keyboardHeight = keyboardFrame.cgRectValue.height
//
//        inputBottomConstraint.constant = -keyboardHeight
//
//        UIView.animate(withDuration: 0.3) {
//            self.view.layoutIfNeeded()
//        }
//
//        scrollToBottom()
//    }

    @objc func keyboardWillHide(notification: Notification) {
        inputBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }



    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func sendMessage() {
        guard let text = messageField.text,
              !text.isEmpty,
              let user = Auth.auth().currentUser else { return }

        let messageData: [String: Any] = [
            "text": text,
            "senderId": user.uid,
            "username": user.displayName ?? "Unknown",
            "timestamp": FieldValue.serverTimestamp()
        ]

        if let planId = currentPlanId {
            // ✅ Sending to group chat
            let messageRef = db.collection("groupChats")
                .document(planId)
                .collection("messages")
                .document()

            messageRef.setData(messageData) { error in
                if let error = error {
                    print("❌ Error sending group message: \(error)")
                } else {
                    self.messageField.text = ""

                    self.db.collection("groupChats")
                        .document(planId)
                        .updateData([
                            "lastMessage": [
                                "text": text,
                                "timestamp": FieldValue.serverTimestamp()
                            ]
                        ])
                }
            }
        } else if let friend = recipientUser {
            // ✅ Sending to private chat
            let chatId = privateChatId(with: friend.id)

            let messageRef = db.collection("privateChats")
                .document(chatId)
                .collection("messages")
                .document()

            messageRef.setData(messageData) { error in
                if let error = error {
                    print("❌ Error sending private message: \(error)")
                } else {
                    self.messageField.text = ""

                    // Optional: store lastMessage in chat metadata if needed
                    self.db.collection("privateChats")
                        .document(chatId)
                        .updateData([
                            "lastMessage": [
                                "text": text,
                                "timestamp": FieldValue.serverTimestamp()
                            ]
                        ])
                }
            }
        }
    }

    
    func startGroupChatListener(planId: String) {
        listener = db.collection("groupChats")
            .document(planId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener{[weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting messages: \(error)")
                    return
                }
                
                self.messages = snapshot?.documents.compactMap{ doc in
                    let data = doc.data()
                    guard let text = data["text"] as? String,
                          let senderId = data["senderId"] as? String,
                          let username = data["username"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    
                    return Message(
                        id: doc.documentID,
                        text: text,
                        senderId: senderId,
                        username: username,
                        timestamp: timestamp
                    )
                    
                } ?? []
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        
    }
    
    func ensurePrivateChatExists(with friend: User) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        let chatId = privateChatId(with: friend.id)
        let chatRef = db.collection("privateChats").document(chatId)

        chatRef.getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                print("✅ Chat already exists: \(chatId)")
                return
            }

            let chatData: [String: Any] = [
                "participants": [currentUID, friend.id],
                "createdAt": FieldValue.serverTimestamp()
            ]

            chatRef.setData(chatData) { error in
                if let error = error {
                    print("❌ Failed to create chat:", error.localizedDescription)
                } else {
                    print("✅ Created private chat:", chatId)
                }
            }
        }
    }

    
    func privateChatId(with friendId: String) -> String {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        let sortedIds = [currentUserId, friendId].sorted()
        return sortedIds.joined(separator: "_")
    }
    
    func startPrivateChatListener(with friend: User) {
        if let user = Auth.auth().currentUser {
            print("✅ Authenticated as: \(user.uid)")
        } else {
            print("❌ No user authenticated")
        }
        
        let chatId = privateChatId(with: friend.id)

        listener = db.collection("privateChats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener{[weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting messages: \(error)")
                    return
                }
                
                self.messages = snapshot?.documents.compactMap{ doc in
                    let data = doc.data()
                    guard let text = data["text"] as? String,
                          let senderId = data["senderId"] as? String,
                          let username = data["username"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    
                    return Message(
                        id: doc.documentID,
                        text: text,
                        senderId: senderId,
                        username: username,
                        timestamp: timestamp
                    )
                    
                } ?? []
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        
    }
    
    func scrollToBottom() {
        guard messages.count > 0 else { return }
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    func setupTitleView(user: User) {
        let titleView = UIStackView()
        titleView.axis = .horizontal
        titleView.spacing = 8

        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder")  // Load from URL if available
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let label = UILabel()
        label.text = user.username
        label.font = UIFont.boldSystemFont(ofSize: 17)

        titleView.addArrangedSubview(imageView)
        titleView.addArrangedSubview(label)

        navigationItem.titleView = titleView
    }

    
    
}



extension MessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let message = messages[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageBubbleCell
//
//        cell.configure(with: message, currentUserId: currentUID)
//
//        return cell
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageBubbleCell
        cell.configure(with: message, currentUserId: currentUID)
        return cell
    }


}
