//
//  BookmarkedViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/5/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class BookmarkedViewController: UIViewController, UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    var bookmarked: [Memory] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        fetchBookmarkedMemories { [weak self] bookmarkedMemories in
            self?.bookmarked = bookmarkedMemories
            self?.tableView.reloadData()
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func fetchBookmarkedMemories(completion: @escaping ([Memory]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        let db = Firestore.firestore()
        let bookmarkedRef = db.collection("users").document(currentUID).collection("bookmarked")

        bookmarkedRef.getDocuments(source: .default) { snapshot, error in
            if let error = error {
                print("❌ Failed to get bookmarked: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let docs = snapshot?.documents else {
                print("📭 No bookmarked posts found")
                completion([])
                return
            }

            let postIds = docs.compactMap { $0.data()["postId"] as? String }
            var bookmarkedMemories: [Memory] = []
            let dispatchGroup = DispatchGroup()

            for postId in postIds {
                dispatchGroup.enter()
                db.collection("memories").document(postId).getDocument(source: .default) { memorySnapshot, error in
                    defer { dispatchGroup.leave() }

                    if let error = error {
                        print("❌ Failed to get memory for \(postId): \(error.localizedDescription)")
                        return
                    }

                    guard let data = memorySnapshot?.data() else { return }

                    let memory = Memory (
                        id: memorySnapshot!.documentID,
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
                    print("HERE IS THE BOOKMARKED: \(memory)")
                    bookmarkedMemories.append(memory)
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(bookmarkedMemories)
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

extension BookmarkedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarked.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as? BookmarkCell else {
            return UITableViewCell()
        }

        let memory = bookmarked[indexPath.row]
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
                cell.recommendButton.setImage(UIImage(systemName: iconName), for: .normal)
            }
        }
        
        bookmarkRef.getDocument { snapshot, _ in
            let isBookmarked = snapshot?.exists == true
            let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
            DispatchQueue.main.async {
                cell.bookmarkedButton.setImage(UIImage(systemName: iconName), for: .normal)
            }
            
        }

        // Set tap behavior
        cell.onRecommendTapped = { [weak self] in
            self?.toggleRecommend(for: postId) { isRecommended in
                DispatchQueue.main.async {
                    let iconName = isRecommended ? "megaphone.fill" : "megaphone"
                    cell.recommendButton.setImage(UIImage(systemName: iconName), for: .normal)
                }
            }
        }
        
        cell.onBookmarkTapped = { [weak self] in
            self?.toggleBookmark(for: postId) { isBookmarked in
                DispatchQueue.main.async {
                    let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
                    cell.bookmarkedButton.setImage(UIImage(systemName: iconName), for: .normal)
                }
            }
        }
        

        return cell
    }
    
}
