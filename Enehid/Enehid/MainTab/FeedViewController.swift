//
//  ViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 4/8/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class FeedViewController: RefreshableViewController, UITableViewDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var storyCollectionView: UICollectionView!
    @IBOutlet weak var feedTableView: UITableView!
    
    var feedMemories: [Memory] = []
    var feedStories : [Story] = []
    var selectedStory: Story?
    
    var isBookmarked = false
    var isStarred = false
    
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
        
        feedTableView.backgroundColor = UIColor(named: "SoftPurple")
        
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
        
        fetchFriendFeed {feedMemories in
            self.feedMemories = feedMemories
            self.emptyStateView.isHidden = !self.feedMemories.isEmpty
            self.feedTableView.reloadData()
        }
        
        fetchStories { feedStories in
            self.feedStories = feedStories
            self.storyCollectionView.reloadData()
        }
    }
    
    override func handleRefresh() {
        print("🔁 FeedViewController refreshing...")
        feedMemories.removeAll()
        feedStories.removeAll()
        feedTableView.reloadData()
        storyCollectionView.reloadData()
        
        let group = DispatchGroup()
        
        group.enter()
        fetchFriendFeed { feedMemories in
            self.feedMemories = feedMemories
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
            }
            group.leave()
        }
        
        group.enter()
        fetchStories { feedStories in
            self.feedStories = feedStories
            DispatchQueue.main.async {
                self.storyCollectionView.reloadData()
            }
            group.leave()
        }
        
        // End refresh once both calls complete
        group.notify(queue: .main) {
            self.endRefreshing()
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
                                        mediaURL: data["storyImageURL"] as? String ?? "",
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
    
    func toggleStarred(for postId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let starredRef = db
            .collection("users")
            .document(currentUID)
            .collection("starred")
            .document(postId)
        
        starredRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Error checking starred status: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if snapshot?.exists == true {
                // ❌ Unstar
                starredRef.delete { error in
                    if let error = error {
                        print("❌ Failed to unstar: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("⭐️ Unstarred post \(postId)")
                        completion(false) // no longer starred
                    }
                }
            } else {
                // ✅ Star
                starredRef.setData([
                    "postId": postId,
                    "starredAt": Timestamp()
                ]) { error in
                    if let error = error {
                        print("❌ Failed to star: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("🌟 Starred post \(postId)")
                        completion(true)
                    }
                }
            }
        }
    }
    
    
    func handleAddToPlan(for memory: Memory) {
        let planId = memory.planId
        let db = Firestore.firestore()
        
        db.collection("plans").document(planId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch plan: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ No plan data found")
                return
            }
            
            guard let location = data["location"] as? String,
                  let activityName = data["activityName"] as? String,
                  let date = data["date"] as? String,
                  let createdBy = data["createdBy"] as? String,
                  let lat = data["lat"] as? Double,
                  let lon = data["lon"] as? Double,
                  let participants = data["participants"] as? [String: String],
                  let acceptedByIDs = data["acceptedByIDs"] as? [String],
                  let declinedByIDs = data["declinedByIDs"] as? [String] else {
                print("❌ Malformed plan data")
                return
            }
            
            // Construct the Plans object
            let plan = Plans(
                id: planId,
                activityName: activityName,
                location: location,
                date: date,
                createdBy: createdBy,
                lat: lat,
                lon: lon,
                participants: participants,
                acceptedByIDs: Set(acceptedByIDs),
                declinedByIDs: Set(declinedByIDs),
                iAccepted: acceptedByIDs.contains(currentUserUID),
                iDeclined: declinedByIDs.contains(currentUserUID)
            )
            
            // Push to new plan screen
            self.goToNewPlanScreen(prefillPlan: plan)
        }
    }
    
    func goToNewPlanScreen(prefillPlan: Plans) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newPlanVC = storyboard.instantiateViewController(withIdentifier: "NewPlanViewController") as! NewPlanViewController
        
        newPlanVC.prefillFromPlan = prefillPlan  // ← we'll define this in the next step
        
        self.navigationController?.pushViewController(newPlanVC, animated: true)
    }
    
    func openComments(for memoryId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        vc.memoryId = memoryId
        
        // Show as a bottom sheet modal
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(vc, animated: true)
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
        // Recommend button
        cell.onRecommendTapped = { [weak self] in
            guard let self = self else { return }
            
            self.toggleRecommend(for: memory.id) { isRecommended in
                DispatchQueue.main.async {
                    let iconName = isRecommended ? "megaphone.fill" : "megaphone"
                    cell.reecommendButton.setImage(UIImage(systemName: iconName), for: .normal)
                }
            }
        }
        // Add to plan Button
        cell.onAddToPlanTapped = { [weak self] memory in
            self?.handleAddToPlan(for: memory)
        }
        // Comment button
        cell.onCommentTapped = { [weak self] in
            self?.openComments(for: memory.id)
        }
        // Bookmark Button - in more
        cell.onBookmarkTapped = { [weak self] completion in
            guard let self = self else { return }
            
            self.toggleBookmark(for: memory.id) { isNowBookmarked in
                DispatchQueue.main.async {
                    completion(isNowBookmarked) // 💥 send updated state BACK to cell
                }
            }
        }
        // Star Button - in more
        cell.onStarTapped = { [weak self] completion in
            guard let self = self else { return }
            
            self.toggleStarred(for: memory.id) { isNowStarred in
                DispatchQueue.main.async {
                    completion(isNowStarred) // 💥 send updated state BACK to cell
                }
            }
        }
        // Open In Maps Button - in more
        cell.onOpenMapsTapped = { [weak self] memory in
            guard let self = self else { return }
            
            let planId = memory.planId
            Firestore.firestore().collection("plans").document(planId).getDocument { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch plan for map: \(error)")
                    return
                }
                
                guard let data = snapshot?.data(),
                      let lat = data["lat"] as? Double,
                      let lon = data["lon"] as? Double,
                      let location = data["location"] as? String else {
                    print("❌ Missing lat/lon or location in plan")
                    return
                }
                
                // Push to MapViewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
                    mapVC.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    mapVC.locationName = location
                    self.navigationController?.pushViewController(mapVC, animated: true)
                }
            }
        }
        
        
        
        
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
        
        let starredRef = Firestore.firestore()
            .collection("users")
            .document(currentUID)
            .collection("starred")
            .document(postId)
        
        recommendRef.getDocument { snapshot, _ in
            let isRecommended = snapshot?.exists == true
            let iconName = isRecommended ? "megaphone.fill" : "megaphone"
            DispatchQueue.main.async {
                cell.reecommendButton.setImage(UIImage(systemName: iconName), for: .normal)
            }
        }
        
        // Bookmark
        bookmarkRef.getDocument { snapshot, _ in
            self.isBookmarked = snapshot?.exists == true
            
            // Starred
            starredRef.getDocument { snapshot, _ in
                self.isStarred = snapshot?.exists == true
                
                DispatchQueue.main.async {
                    cell.updateStatusIcons(isBookmarked: self.isBookmarked, isStarred: self.isStarred)
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

