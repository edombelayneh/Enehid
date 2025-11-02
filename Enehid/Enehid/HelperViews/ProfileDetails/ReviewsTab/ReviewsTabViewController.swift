//
//  ReviewsTabViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ReviewsTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendedMemories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1. Dequeue a reusable cell to save memory.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewsCell", for: indexPath) as! ReviewsCell

        // 2. Get the correct 'Memory' object from your array using the cell's index.
        let recommendedMemories = self.recommendedMemories[indexPath.item]

        // 3. Set the image on the cell's image view.
        // Make sure the image name matches your asset catalog!
//        cell.reviewsImageView.image = UIImage(named: recommendedMemories.imageName)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 1.0
        let numberOfColumns: CGFloat = 3.0
        
        let totalWidth = collectionView.frame.width
        let totalSpacing = (numberOfColumns - 1) * spacing
        let availableWidth = totalWidth - totalSpacing
        
        let cellWidth = availableWidth / numberOfColumns
        return CGSize(width: cellWidth, height: cellWidth)
    }
    

    
    @IBOutlet weak var collectionView: UICollectionView!
//    var reviews: [Reviews] = sampleReviews
    var recommendedMemories: [Memory] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        
        fetchRecommendedMemories { [weak self] memories in
            self?.recommendedMemories = memories
            self?.collectionView.reloadData()
        }
//        collectionView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchRecommendedMemories(completion: @escaping ([Memory]) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        let db = Firestore.firestore()
        let recommendsRef = db.collection("users").document(currentUID).collection("recommends")

        recommendsRef.getDocuments(source: .default) { snapshot, error in
            if let error = error {
                print("❌ Failed to get recommends: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let docs = snapshot?.documents else {
                print("📭 No recommended posts found")
                completion([])
                return
            }

            let postIds = docs.compactMap { $0.data()["postId"] as? String }
            var recommendedMemories: [Memory] = []
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
                    print("HERE IS THE MEMORY: \(memory)")
                    recommendedMemories.append(memory)
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(recommendedMemories)
            }
        }
    }

            
            
        
        
        
    

}
