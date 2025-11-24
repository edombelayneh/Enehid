//
//  ViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UIViewController, UITableViewDelegate, UICollectionViewDelegate {
    
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var storyCollectionView: UICollectionView!
    @IBOutlet weak var feedTableView: UITableView!
    
    var feedMemories: [Memory] = []
    var feedStories : [Story] = []
    var selectedStory: Story?
    
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
    
    @IBAction func onTappedNewMemory(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mediaPickerVC = storyboard.instantiateViewController(withIdentifier: "MediaPickerVC") as? MediaPickerViewController {
            self.navigationController?.pushViewController(mediaPickerVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
        
        fetchFriendFeed {feedMemories in
            self.feedMemories = feedMemories
            self.feedTableView.reloadData()
        }
        
        fetchStories { feedStories in
            self.feedStories = feedStories
            self.storyCollectionView.reloadData()
        }
    }
    
    func fetchStories(completion: @escaping ([Story]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion([])
            return
        }
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let friendsUIDs = data["friends"] as? [String:String] else {
                print("Failed to get Friends list")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var allStories: [Story] = []
            
            for friendUID in friendsUIDs {
                print(friendUID.key)
                dispatchGroup.enter()
                self.db.collection("users").document(friendUID.key).getDocument { userSnapshot, _ in
                    let avatarURL = userSnapshot?.data()?["profilePictureURL"] as? String ?? ""
                    let twentyFourHoursAgo = Date().addingTimeInterval(-86400)
                    
                    self.db.collection("story")
                        .whereField("ownerId", isEqualTo: friendUID.key)
                        .whereField("createdAt", isGreaterThan: twentyFourHoursAgo)
                    //                        .whereField("isExpired", isEqualTo: false)
                        .order(by: "createdAt", descending: true)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("error: \(error.localizedDescription)")
                                completion([])
                            }
                            if let docs = snapshot?.documents {
                                
                                let stories = docs.compactMap { doc -> Story in
                                    let data = doc.data()
                                    return Story (
                                        id: doc.documentID,
                                        ownerId: data["ownerId"] as? String ?? "",
                                        username: data["username"] as? String ?? "",
                                        profilePictureURL: avatarURL,
                                        mediaURL: data["mediaURL"] as? String ?? "",
                                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                                        //                                        isExpired: data["isExpired"] as? Bool ?? false
                                    )
                                }
                                allStories.append(contentsOf: stories)
                            }
                            dispatchGroup.leave()
                        }
                }
            }
            dispatchGroup.notify(queue: .main) {
                let shuffled = allStories.shuffled()
                completion(shuffled)
            }
        }
    }
    
    func fetchFriendFeed (completion: @escaping ([Memory]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion([])
            return
        }
        
        db.collection("users").document(currentUID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let friendsUIDs = data["friends"] as? [String:String] else {
                print("Failed to get Friends list")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var allMemories: [Memory] = []
            
            for friendUID in friendsUIDs {
                print(friendUID.key)
                dispatchGroup.enter()
                
                self.db.collection("memories")
                    .whereField("ownerId", isEqualTo: friendUID.key)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 2)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("error: \(error.localizedDescription)")
                            
                            completion([])
                        }
                        
                        if let docs = snapshot?.documents {
                            print(docs)
                            let memories = docs.compactMap { doc -> Memory in
                                
                                print(doc)
                                let data = doc.data()
                                
                                return Memory (
                                    id: doc.documentID,
                                    ownerId: data["ownerId"] as? String ?? "",
                                    username: data["username"] as? String ?? "",
                                    caption: data["caption"] as? String ?? "",
                                    recommends: data["recommends"] as? Int ?? 0,
                                    memoryURLs: data["memoryURLs"] as? [String] ?? [],
                                    bookmarks: data["bookmarks"] as? Int ?? 0,
                                    taggedUIds: data["taggedUIds"] as? [String] ?? [],
                                    commentsCount: data["commentsCount"] as? Int ?? 0,
                                    createdAt: (data["createdAt"] as? Timestamp) ?? Timestamp(),
                                    visibility: data["visibility"] as? String ?? "friends",
                                    planId: data["planId"] as? String ?? ""
                                )
                            }
                            allMemories.append(contentsOf: memories)
                        }
                        dispatchGroup.leave()
                    }
            }
            dispatchGroup.notify(queue: .main) {
                let shuffled = allMemories.shuffled()
                let limited = Array(shuffled.prefix(20))
                completion(limited)
            }
        }
    }
    
    func toggleBookmark(for postId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let bookmarkeRef = db
            .collection("users")
            .document(currentUID)
            .collection("bookmarked")
            .document(postId)
        
        bookmarkeRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Error checking bookmarked status: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if snapshot?.exists == true {
                // ❌ Unrecommend
                bookmarkeRef.delete { error in
                    if let error = error {
                        print("❌ Failed to un-bookmark: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("📎 Unbookmarked post \(postId)")
                        completion(false) // now not bookmark
                    }
                }
            } else {
                // ✅ Recommend
                bookmarkeRef.setData([
                    "postId": postId,
                    "bookmarkedAt": Timestamp()
                ]) { error in
                    if let error = error {
                        print("❌ Failed to bookmark: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("📑 Bookmarked post \(postId)")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func toggleRecommend(for postId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let recommendRef = db
            .collection("users")
            .document(currentUID)
            .collection("recommends")
            .document(postId)
        
        recommendRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Error checking recommend status: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if snapshot?.exists == true {
                // ❌ Unrecommend
                recommendRef.delete { error in
                    if let error = error {
                        print("❌ Failed to un-recommend: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("🔕 Unrecommended post \(postId)")
                        completion(false) // now not recommended
                    }
                }
            } else {
                // ✅ Recommend
                recommendRef.setData([
                    "postId": postId,
                    "recommendedAt": Timestamp()
                ]) { error in
                    if let error = error {
                        print("❌ Failed to recommend: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("📢 Recommended post \(postId)")
                        completion(true)
                    }
                }
            }
        }
    }
    
    
    
}

extension FeedViewController: UITableViewDataSource, UICollectionViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedMemories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        let memory = feedMemories[indexPath.row]
        cell.configure(with: memory)
        
        // Configure recommend icon based on current state
        let postId = memory.id
        let currentUID = Auth.auth().currentUser?.uid ?? ""
        let recommendRef = Firestore.firestore()
            .collection("users")
            .document(currentUID)
            .collection("recommends")
            .document(postId)
        
        let bookmarkRef = Firestore.firestore()
            .collection("users")
            .document(currentUID)
            .collection("bookmarked")
            .document(postId)
        
        recommendRef.getDocument { snapshot, _ in
            let isRecommended = snapshot?.exists == true
            let iconName = isRecommended ? "megaphone.fill" : "megaphone"
            DispatchQueue.main.async {
                cell.reecommendButton.setImage(UIImage(systemName: iconName), for: .normal)
            }
        }
        
        bookmarkRef.getDocument { snapshot, _ in
            let isBookmarked = snapshot?.exists == true
            let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
            DispatchQueue.main.async {
                cell.bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
            }
            
        }
        
        // Set tap behavior
        cell.onRecommendTapped = { [weak self] in
            self?.toggleRecommend(for: postId) { isRecommended in
                DispatchQueue.main.async {
                    let iconName = isRecommended ? "megaphone.fill" : "megaphone"
                    cell.reecommendButton.setImage(UIImage(systemName: iconName), for: .normal)
                }
            }
        }
        
        cell.onBookmarkTapped = { [weak self] in
            self?.toggleBookmark(for: postId) { isBookmarked in
                DispatchQueue.main.async {
                    let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
                    cell.bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
                }
            }
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as? StoryCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: feedStories[indexPath.item])
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPostSegue" {
            let destinationVC = segue.destination as! PostDetailViewController
            
            // If segue triggered by tapping the entire cell
            if let indexPath = feedTableView.indexPathForSelectedRow {
                let selectedPost = feedMemories[indexPath.row]
                destinationVC.feedMemories = selectedPost
                print("✅ Passing post to PostVC via cell tap: \(selectedPost)")
            }
        }
        else if segue.identifier == "ShowStorySegue" {
            let destinationVC = segue.destination as! StoryDetailsViewController
            if let selectedIndexPaths = storyCollectionView.indexPathsForSelectedItems,
               let indexPath = selectedIndexPaths.first {
                
                let selectedStory = feedStories[indexPath.item]
                destinationVC.story = selectedStory
                print("✅ Passing story to StoryDetailVC via collectionView index: \(selectedStory)")
                
            } else {
                print("⚠️ No story selected.")
            }
        }
    }
    
}

