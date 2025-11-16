//
//  UserService.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/16/25.
//

import FirebaseFirestore
import FirebaseAuth

class UserService {
    static let shared = UserService()
    let db = Firestore.firestore()

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
