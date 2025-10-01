//
//  StarsTabViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit

class StarsTabViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.starred.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1. Dequeue a reusable cell to save memory.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarredCell", for: indexPath) as! StarredCell

        // 2. Get the correct 'Memory' object from your array using the cell's index.
        let starred = self.starred[indexPath.item]

        // 3. Set the image on the cell's image view.
        // Make sure the image name matches your asset catalog!
        cell.starredImageView.image = UIImage(named: starred.imageName)

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
    
    var starred: [Starred] = sampleStarred
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        collectionView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
