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
    
    
    @IBOutlet weak var storyCollectionView: UICollectionView!
    @IBOutlet weak var feedTableView: UITableView!
    
    var feedMemories: [Memory] = []
    var feedStories : [Story] = []
    var selectedStory: Story?

    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid ?? ""
    
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
//                print(snapshot?.data())
//                print("Error: \(error?.localizedDescription)")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var allStories: [Story] = []
            
            for friendUID in friendsUIDs {
                print(friendUID.key)
                dispatchGroup.enter()
                print("I'm here 0 - \(friendUID.value)")
                
                self.db.collection("story")
                    .whereField("ownerId", isEqualTo: friendUID.key)
                    .order(by: "createdAt", descending: true)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("error: \(error.localizedDescription)")
                            print("I'm here 1 - \(friendUID.value)")
                            completion([])
                        }
                        print("I'm here 2 - \(friendUID.value)")
                        if let docs = snapshot?.documents {
                            print("I'm here 3 - \(friendUID.value)")
                            print(docs)
                            let stories = docs.compactMap { doc -> Story in
                                print("I'm here 4 - \(friendUID.value)")
                                print(doc)
                                let data = doc.data()
                                print("I'm here 5 - \(friendUID.value)")
                                return Story (
                                    id: doc.documentID,
                                    ownerId: data["ownerId"] as? String ?? "",
                                    username: data["username"] as? String ?? "",
                                    mediaURL: data["mediaURL"] as? String ?? "",
                                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                                )
                            }
                            allStories.append(contentsOf: stories)
                        }
                        dispatchGroup.leave()
                    }
            }
            dispatchGroup.notify(queue: .main) {
                let shuffled = allStories.shuffled()
//                let limited = Array(shuffled.prefix(20))
                completion(shuffled)
            }
        }
        
//        db.collection("users").document(currentUID).getDocument(completion: { snapshot, error in
//            guard let data = snapshot?.data(),
//                  let friendUIDs = data["friends"] as? [String:String]
//            else {
//                print("❌ Failed to get Friends list for stories.")
//                completion([])
//                return
//            }
//            
//            self.db.collection("story").getDocuments(completion:{ snapshot, error in
//                guard let docs = snapshot?.documents
//                else {
//                    print("❌ Failed to fetch stories.")
//                    completion([])
//                    return
//                }
//                
//                let friendStories = docs.compactMap { doc -> Story? in
//                    let data = doc.data()
//                    let ownerId = data["ownerId"] as? String ?? ""
//                    guard friendUIDs.keys.contains(ownerId) else { return nil }
//                    
//                    return Story(
//                        id: doc.documentID,
//                        ownerId: ownerId,
//                        username: data["username"] ass? String ?? "",
//                        mediaURL: data["mediaURL"] as? String ?? "",
//                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
//                    )
//                }
//                let sortedStories = friendStories.sorted(by: { $0.createdAt > $1.createdAt })
//                completion(sortedStories)
//            })
//        })
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
//                print(snapshot?.data())
//                print("Error: \(error?.localizedDescription)")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var allMemories: [Memory] = []
            
            for friendUID in friendsUIDs {
                print(friendUID.key)
                dispatchGroup.enter()
//                print("I'm here 0 - \(friendUID.value)")
                
                self.db.collection("memories")
                    .whereField("ownerId", isEqualTo: friendUID.key)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 2)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("error: \(error.localizedDescription)")
//                            print("I'm here 1 - \(friendUID.value)")
                            completion([])
                        }
//                        print("I'm here 2 - \(friendUID.value)")
                        if let docs = snapshot?.documents {
//                            print("I'm here 3 - \(friendUID.value)")
                            print(docs)
                            let memories = docs.compactMap { doc -> Memory in
//                                print("I'm here 4 - \(friendUID.value)")
                                print(doc)
                                let data = doc.data()
//                                print("I'm here 5 - \(friendUID.value)")
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
                                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
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
    
    
    
}

extension FeedViewController: UITableViewDataSource, UICollectionViewDataSource {
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedMemories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        cell.configure(with: feedMemories[indexPath.row])
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStory = feedStories[indexPath.item]
        performSegue(withIdentifier: "ShowStorySegue", sender: self)
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
            if let selectedStory = selectedStory {
                destinationVC.story = selectedStory
                print("✅ Passing story to StoryDetailVC via cell tap: \(selectedStory)")
            } else {
                print("⚠️ No story selected.")
            }
        }
    }

}

