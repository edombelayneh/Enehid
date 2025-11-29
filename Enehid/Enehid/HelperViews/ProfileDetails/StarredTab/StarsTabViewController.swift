//
//  StarsTabViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class StarsTabViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RefreshableTab {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let db = Firestore.firestore()
    
    var starred: [Memory] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view
        fetchStarredMemories()
        collectionView.reloadData()
    }
    
    func refreshContent() {
        print("🔁 Refreshing StarredVC")
        fetchStarredMemories()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // MARK: - Fetch Starred
    
    func fetchStarredMemories() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let starredRef = db.collection("users").document(currentUID).collection("starred")
        
        starredRef.getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            let memoryIds = docs.map { $0.documentID }
            
            let group = DispatchGroup()
            var fetchedMemories: [Memory] = []
            
            for id in memoryIds {
                group.enter()
                
                self.db.collection("memories").document(id).getDocument { doc, error in
                    defer { group.leave() }
                    
                    guard let data = doc?.data(), error == nil else { return }
                    
                    let memory = Memory(
                        id: doc?.documentID ?? "",
                        ownerId: data["ownerId"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        caption: data["caption"] as? String ?? "",
                        recommends: data["recommends"] as? Int ?? 0,
                        memoryURLs: data["memoryURLs"] as? [String] ?? [],
                        bookmarks: data["bookmarks"] as? Int ?? 0,
                        taggedUIds: data["taggedUIds"] as? [String] ?? [],
                        commentsCount: data["commentsCount"] as? Int ?? 0,
                        createdAt: data["createdAt"] as? Timestamp ?? Timestamp(date: Date()),
                        visibility: data["visibility"] as? String ?? "public",
                        planId: data["planId"] as? String ?? ""
                    )
                    
                    fetchedMemories.append(memory)
                }
            }
            
            group.notify(queue: .main) {
                self.starred = fetchedMemories
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starred.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarredCell", for: indexPath) as! StarredCell
        let memory = starred[indexPath.item]
        
        if let firstImageURL = memory.memoryURLs.first,
           let url = URL(string: firstImageURL) {
            cell.starredImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
        
        return cell
    }
    
    // MARK: - Layout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 1
        let totalSpacing = (numberOfColumns - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / numberOfColumns
        
        return CGSize(width: floor(width), height: floor(width))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        if numberOfItems == 1 {
            let cellWidth = (collectionView.bounds.width - 2) / 3
            let rightInset = collectionView.bounds.width - cellWidth
            return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: rightInset)
        }
        
        return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
