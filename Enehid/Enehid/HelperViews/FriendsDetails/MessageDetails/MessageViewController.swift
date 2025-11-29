//
//  MessageViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/29/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class MessageViewController: UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var inputBottomView: UIView!
    @IBOutlet weak var inputBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewPlansButton: UIButton!
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    var messages: [Message] = []
    
    var listener: ListenerRegistration?
    var currentPlan: Plans?
    var currentPlanId: String?
    var recipientUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        // Hide or show viewPlansButton based on chat type
        viewPlansButton.isHidden = (currentPlanId == nil)
        
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
        tableView.contentInsetAdjustmentBehavior = .always
        
        tableView.register(MessageBubbleCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        
        if let planId = currentPlanId {
            setupGroupChatTitleView(groupName: "Group Chat")
            startGroupChatListener(planId: planId)
            
            checkChatAccess(for: planId) { canSend in
                DispatchQueue.main.async {
                    self.inputBottomView.isHidden = !canSend
                    if !canSend {
                        self.showReadOnlyBanner() // optional helper function
                    }
                }
            }
        } else if let user = recipientUser {
            setupTitleView(user: user)
            ensurePrivateChatExists(with: user)
            startPrivateChatListener(with: user)
        }
        
        
    }
    
    @IBAction func onTapSendMessage(_ sender: UIButton) {
        sendMessage()
    }
    @IBAction func onTapViewButton(_ sender: UIButton) {
        guard let planId = currentPlanId else {
            print("❌ No planId found.")
            return
        }
        
        db.collection("plans").document(planId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching plan: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ Plan document is empty or doesn't exist.")
                return
            }
            
            // 👇 Parse all required fields manually
            let activityName = data["activityName"] as? String ?? ""
            let location = data["location"] as? String ?? ""
            let date = data["date"] as? String ?? ""
            let createdBy = data["createdBy"] as? String ?? ""
            let lat = data["lat"] as? Double ?? 0.0
            let lon = data["lon"] as? Double ?? 0.0
            let participants = data["participants"] as? [String: String] ?? [:]
            let acceptedByIDs = data["acceptedByIDs"] as? Set<String> ?? []
            let declinedByIDs = data["declinedByIDs"] as? Set<String> ?? []
            let iAccepted = data["iAccepted"] as? Bool ?? false
            let iDeclined = data["iDeclined"] as? Bool ?? false
            
            let plan = Plans(
                id: planId,
                activityName: activityName,
                location: location,
                date: date,
                createdBy: createdBy,
                lat: lat,
                lon: lon,
                participants: participants,
                acceptedByIDs: acceptedByIDs,
                declinedByIDs: declinedByIDs,
                iAccepted: iAccepted,
                iDeclined: iDeclined
            )
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let detailVC = storyboard.instantiateViewController(withIdentifier: "PlanDetailsViewController") as? PlanDetailsViewController {
                    detailVC.plan = plan
                    detailVC.modalPresentationStyle = .pageSheet 
                    self.present(detailVC, animated: true, completion: nil)

                } else {
                    print("❌ Could not load PlanDetailsViewController")
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        inputBottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curve << 16),
                       animations: {
            self.view.layoutIfNeeded()
            self.scrollToBottom() // important!
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        inputBottomConstraint.constant = 0
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curve << 16),
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
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
        
        // ✅ GROUP CHAT FLOW (check plan access)
        if let planId = currentPlanId {
            checkChatAccess(for: planId) { canSend in
                guard canSend else {
                    print("❌ You must accept the plan to send messages.")
                    return
                }
                
                let messageRef = self.db.collection("groupChats")
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
            }
            
            // ✅ PRIVATE CHAT FLOW (no access check needed)
        } else if let friend = recipientUser {
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
    
    
    func checkChatAccess(for planId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let chatRef = db.collection("groupChats").document(planId)
        chatRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let participants = data["participants"] as? [String: [String: Any]],
                  let status = participants[uid]?["status"] as? String else {
                completion(false) // fallback to read-only
                return
            }
            
            completion(status == "accepted") // true if they can send messages
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
    
    //    func setupTitleView(user: User) {
    //        let titleView = UIStackView()
    //        titleView.axis = .horizontal
    //        titleView.spacing = 8
    //
    //        let imageView = UIImageView()
    //        imageView.image = UIImage(named: "placeholder")  // Load from URL if available
    //        imageView.layer.cornerRadius = 15
    //        imageView.clipsToBounds = true
    //        imageView.contentMode = .scaleAspectFill
    //        imageView.translatesAutoresizingMaskIntoConstraints = false
    //        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
    //        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    //
    //        let label = UILabel()
    //        label.text = user.username
    //        label.font = UIFont.boldSystemFont(ofSize: 17)
    //
    //        titleView.addArrangedSubview(imageView)
    //        titleView.addArrangedSubview(label)
    //
    //        navigationItem.titleView = titleView
    //    }
    
    func setupTitleView(user: User) {
        let container = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 17
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        AvatarManager.loadAvatar(from: user.profilePictureURL, into: imageView, cropToFace: true)
        
        let label = UILabel()
        label.text = user.username
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        navigationItem.titleView = container
    }
    
    func setupGroupChatTitleView(groupName: String?) {
        let container = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.3")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let label = UILabel()
        label.text = groupName ?? "Group Chat"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        navigationItem.titleView = container
    }
    
    func showReadOnlyBanner() {
        let banner = UILabel()
        banner.text = "You haven't accepted this plan yet. Join to chat."
        banner.font = UIFont.systemFont(ofSize: 13)
        banner.textAlignment = .center
        banner.textColor = .white
        banner.backgroundColor = .systemOrange
        banner.layer.cornerRadius = 6
        banner.layer.masksToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(banner)
        
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            banner.bottomAnchor.constraint(equalTo: inputBottomView.topAnchor, constant: -8),
            banner.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    
    
}

extension MessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageBubbleCell
        
        let isCurrentUser = message.senderId == currentUID
        let avatarURL: String? = isCurrentUser ? nil : recipientUser?.profilePictureURL
        
        cell.configure(
            with: message,
            currentUserId: currentUID,
            senderAvatarURL: message.senderId != currentUID ? recipientUser?.profilePictureURL : nil
        )
        
        return cell
    }
    
    
}




