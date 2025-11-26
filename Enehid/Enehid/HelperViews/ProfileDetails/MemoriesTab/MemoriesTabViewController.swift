//
//  MemoriesTabViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class MemoriesTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let db = Firestore.firestore()
    
    var memories: [Memory] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
        fetchMemories()
        collectionView.reloadData()
        
    }
    
    func fetchMemories() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        print("🧠 Current UID from fetchmemories: \(currentUID)")
        
        let userRef = db.collection("users").document(currentUID).collection("memories")
        
        userRef.order(by: "createdAt", descending: true).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            
            let memoryIds = docs.map { $0.documentID }
            
            let memoryFetchGroup = DispatchGroup()
            var fetchedMemories: [Memory] = []
            
            for id in memoryIds {
                memoryFetchGroup.enter()
                
                self.db.collection("memories").document(id).getDocument { doc, error in
                    if let data = doc?.data() {
                        let memory = Memory(
                            id: data["id"] as? String ?? "",
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
                    memoryFetchGroup.leave()
                }
            }
            
            memoryFetchGroup.notify(queue: .main) {
                self.memories = fetchedMemories
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryCell", for: indexPath) as! MemoryCell
        let memory = memories[indexPath.item]
        if let firstImageURL = memory.memoryURLs.first {
            print("🖼️ First image URL: \(firstImageURL)")
            cell.memoryImageView.sd_setImage(with: URL(string: firstImageURL), placeholderImage: UIImage(named: "placeholder"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 1
        
        // Total spacing between items = (columns - 1) * spacing
        let totalSpacing = (numberOfColumns - 1) * spacing
        
        // Adjusted width based on total spacing
        let width = (collectionView.bounds.width - totalSpacing) / numberOfColumns
        
        return CGSize(width: floor(width), height: floor(width)) // square cells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
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
