//
//  MemoriesTabViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit

class MemoriesTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1. Dequeue a reusable cell to save memory.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryCell", for: indexPath) as! MemoryCell

        // 2. Get the correct 'Memory' object from your array using the cell's index.
        let memory = self.memories[indexPath.item]

        // 3. Set the image on the cell's image view.
        // Make sure the image name matches your asset catalog!
        cell.memoryImageView.image = UIImage(named: memory.imageName)

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
    
    var memories: [Memory] = sampleMemory
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
        collectionView.reloadData()

//        self.memories = memories
        
            }
    
}
